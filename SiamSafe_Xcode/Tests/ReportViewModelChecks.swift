import Foundation

// This test double is linked instead of Firebase; all assertions exercise the
// production ReportViewModel, EventService protocol, and DisasterEvent model.
@MainActor
final class FirebaseService: EventService {
    var active: [DisasterEvent] = []
    var resolved: [DisasterEvent] = []
    var fetchFailure = false
    var resolvedFailure = false
    var failingDeletes: Set<String> = []
    var queries: [String] = []
    var deletes: [String] = []
    var pendingFetch: CheckedContinuation<[DisasterEvent], Error>?
    var holdNextFetch = false
    var pendingDelete: CheckedContinuation<Void, Error>?
    var holdNextDelete = false

    func fetchEvents(status: String) async throws -> [DisasterEvent] {
        queries.append(status)
        if holdNextFetch {
            holdNextFetch = false
            return try await withCheckedThrowingContinuation { pendingFetch = $0 }
        }
        if fetchFailure || (status == "resolved" && resolvedFailure) { throw TestError.unavailable }
        return status == "active" ? active : resolved
    }
    func deleteEvent(id: String) async throws {
        deletes.append(id)
        if holdNextDelete {
            holdNextDelete = false
            try await withCheckedThrowingContinuation { pendingDelete = $0 }
        }
        if failingDeletes.contains(id) { throw TestError.unavailable }
        active.removeAll { $0.id == id }
    }
}

enum TestError: Error { case unavailable }

@main
struct ModelChecks {
    @MainActor
    static func main() async {
        func event(_ id: String, _ age: Double = 0, _ severity: Severity = .low,
                   status: String = "active") -> DisasterEvent {
            DisasterEvent(id: id, title: id, description: "Test", type: .flood,
                          severity: severity, latitude: 13, longitude: 100,
                          createdAt: Date(timeIntervalSince1970: age), status: status)
        }
        let service = FirebaseService()
        service.active = [event("old", 1), event("urgent", 3, .critical), event("high", 2, .high)]
        service.resolved = [event("resolved", 4, .critical, status: "resolved")]
        let model = ReportViewModel(service: service)
        await model.fetchEvents()
        precondition(model.events.map(\.id) == ["urgent", "high", "old"])
        precondition(model.urgentEvents.map(\.id) == ["urgent", "high"])
        await model.fetchResolvedEvents()
        precondition(service.queries == ["active", "resolved"])
        precondition(model.resolvedEvents.map(\.id) == ["resolved"])
        precondition(model.eventCount == 3 && model.urgentEventCount == 2)
        print("PASS: status queries, active counts, urgency, newest-first ordering")

        service.resolved = [event("urgent", 4, .critical, status: "resolved")]
        await model.fetchResolvedEvents()
        precondition(model.allEvents.count == 3)
        precondition(Set(model.allEvents.map(\.id)).count == model.allEvents.count)
        print("PASS: status changes between reads do not create duplicate rows")

        service.resolvedFailure = true
        await model.fetchResolvedEvents()
        precondition(model.resolvedErrorMessage != nil && model.errorMessage == nil)
        precondition(model.events.count == 3 && model.resolvedEvents.count == 1)
        service.fetchFailure = true
        await model.fetchEvents()
        precondition(model.errorMessage != nil && !model.isLoading && model.events.count == 3)
        service.fetchFailure = false
        await model.fetchEvents()
        precondition(model.errorMessage == nil)
        print("PASS: failed reads preserve cached data, errors isolated, retry clears error")

        service.holdNextFetch = true
        let stale = Task { await model.fetchEvents() }
        while service.pendingFetch == nil { await Task.yield() }
        model.recordCreatedEvent(event("new", 5))
        service.pendingFetch?.resume(returning: [])
        service.pendingFetch = nil
        await stale.value
        precondition(model.events.first?.id == "new" && model.events.count == 4)
        model.recordCreatedEvent(event("new", 5))
        precondition(model.events.count == 4)
        print("PASS: a stale read cannot erase a newly created event; IDs do not duplicate")

        service.holdNextFetch = true
        let first = Task { await model.fetchEvents() }
        while service.pendingFetch == nil { await Task.yield() }
        await model.fetchEvents()
        service.pendingFetch?.resume(returning: [])
        service.pendingFetch = nil
        await first.value
        precondition(model.events.count == 3 && !model.isLoading)
        print("PASS: an older request cannot overwrite the latest refresh")

        service.failingDeletes = ["high"]
        service.fetchFailure = true
        let failures = await model.deleteEvents(ids: ["old", "high"])
        precondition(failures == ["high"])
        precondition(model.events.map(\.id) == ["urgent", "high"])
        precondition(model.deletionErrorMessage != nil && model.errorMessage != nil && !model.isDeleting)
        precondition(service.deletes == ["high", "old"])
        service.fetchFailure = false
        service.failingDeletes = []
        let retryFailures = await model.deleteEvents(ids: failures)
        precondition(retryFailures.isEmpty && model.events.map(\.id) == ["urgent"])
        precondition(model.deletionErrorMessage == nil)
        print("PASS: partial delete and failed refresh retain successful removals; failed IDs can retry")

        service.holdNextDelete = true
        let deleting = Task { await model.deleteEvents(ids: ["urgent"]) }
        while service.pendingDelete == nil { await Task.yield() }
        let callsBefore = service.deletes.count
        _ = await model.deleteEvents(ids: ["urgent"])
        precondition(service.deletes.count == callsBefore && model.isDeleting)
        service.pendingDelete?.resume()
        service.pendingDelete = nil
        _ = await deleting.value
        precondition(model.events.isEmpty && !model.isDeleting)
        print("PASS: repeated delete actions cannot issue duplicate writes")

        let offline = FirebaseService()
        let preview = ReportViewModel(usePreviewData: true, service: offline)
        await preview.fetchEvents()
        await preview.fetchResolvedEvents()
        _ = await preview.deleteEvents(ids: ["preview-flood"])
        precondition(offline.queries.isEmpty && offline.deletes.isEmpty)
        precondition(preview.events.count == 2)
        precondition(!RuntimeEnvironment.usesMockServices)
        print("PASS: preview operations stay offline; regular runtime uses live services")
    }
}
