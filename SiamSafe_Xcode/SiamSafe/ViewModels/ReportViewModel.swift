import Foundation
import Combine

@MainActor
final class ReportViewModel: ObservableObject {
    // Active events remain the source for the map, overview, and reports.
    @Published var events: [DisasterEvent] = []
    @Published private(set) var resolvedEvents: [DisasterEvent] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingResolved = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var resolvedErrorMessage: String?
    @Published private(set) var isDeleting = false
    @Published private(set) var deletionErrorMessage: String?

    private let service: any EventService
    private let usesPreviewData: Bool
    private var activeRequest = 0
    private var resolvedRequest = 0
    private var mutationRevision = 0

    init(usePreviewData: Bool = false, service: (any EventService)? = nil) {
        self.service = service ?? FirebaseService()
        usesPreviewData = usePreviewData || RuntimeEnvironment.usesMockServices
        if usesPreviewData { events = Self.previewEvents }
    }

    func fetchEvents() async {
        guard !usesPreviewData else { return }
        activeRequest += 1
        let request = activeRequest
        let revision = mutationRevision
        isLoading = true
        errorMessage = nil
        defer { if request == activeRequest { isLoading = false } }
        do {
            let result = try await service.fetchEvents(status: "active")
            guard request == activeRequest, revision == mutationRevision else { return }
            events = newestFirst(result)
        } catch {
            guard request == activeRequest, revision == mutationRevision else { return }
            errorMessage = error.localizedDescription
        }
    }

    // Query resolved records only when requested; do not change the active query
    // or make the existing screens depend on permission to read resolved events.
    func fetchResolvedEvents() async {
        guard !usesPreviewData else { return }
        resolvedRequest += 1
        let request = resolvedRequest
        isLoadingResolved = true
        resolvedErrorMessage = nil
        defer { if request == resolvedRequest { isLoadingResolved = false } }
        do {
            let result = try await service.fetchEvents(status: "resolved")
            guard request == resolvedRequest else { return }
            resolvedEvents = newestFirst(result)
        } catch {
            guard request == resolvedRequest else { return }
            resolvedErrorMessage = error.localizedDescription
        }
    }

    func recordCreatedEvent(_ event: DisasterEvent) {
        mutationRevision += 1
        events.removeAll { $0.id == event.id }
        events = newestFirst(events + [event])
    }

    /// Returns only IDs that could not be deleted, so the UI can retry them.
    func deleteEvents(ids: Set<String>) async -> Set<String> {
        guard !isDeleting else { return ids }
        isDeleting = true
        deletionErrorMessage = nil
        defer { isDeleting = false }
        var failures = Set<String>()
        var firstError: String?
        for id in ids.sorted() {
            do {
                if !usesPreviewData { try await service.deleteEvent(id: id) }
                mutationRevision += 1
                events.removeAll { $0.id == id }
            } catch {
                failures.insert(id)
                if firstError == nil { firstError = error.localizedDescription }
            }
        }
        // Refresh even after a partial failure. Successful removals remain visible
        // in all screens if this refresh also fails.
        await fetchEvents()
        deletionErrorMessage = firstError
        return failures
    }

    var allEvents: [DisasterEvent] {
        // A status can change between separate reads. Keep one row per document.
        let unique = Dictionary((resolvedEvents + events).map { ($0.id, $0) },
                                uniquingKeysWith: { _, latest in latest })
        return newestFirst(Array(unique.values))
    }

    var urgentEvents: [DisasterEvent] {
        newestFirst(events.filter { $0.severity == .high || $0.severity == .critical })
    }
    var eventCount: Int { events.count }
    var urgentEventCount: Int { urgentEvents.count }

    private func newestFirst(_ events: [DisasterEvent]) -> [DisasterEvent] {
        events.sorted {
            $0.createdAt == $1.createdAt ? $0.id < $1.id : $0.createdAt > $1.createdAt
        }
    }

    private static let previewEvents: [DisasterEvent] = [
        DisasterEvent(
            id: "preview-flood",
            title: "น้ำท่วมจำลอง",
            description: "ระดับน้ำสูงในพื้นที่ทดสอบ",
            type: .flood,
            severity: .high,
            latitude: 13.7563,
            longitude: 100.5018,
            createdAt: .now.addingTimeInterval(-1_800),
            status: "active"
        ),
        DisasterEvent(
            id: "preview-fire",
            title: "ไฟไหม้จำลอง",
            description: "เหตุการณ์ตัวอย่างสำหรับ Canvas",
            type: .fire,
            severity: .critical,
            latitude: 13.7467,
            longitude: 100.5347,
            createdAt: .now.addingTimeInterval(-3_600),
            status: "active"
        ),
        DisasterEvent(
            id: "preview-storm",
            title: "พายุจำลอง",
            description: "ลมแรงในพื้นที่ใกล้เคียง",
            type: .storm,
            severity: .medium,
            latitude: 13.7740,
            longitude: 100.5100,
            createdAt: .now.addingTimeInterval(-7_200),
            status: "active"
        )
    ]
}
