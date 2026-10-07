import SwiftUI
import MapKit
import CoreLocation

// MARK: - App Language

enum AppLanguage {

    static var current: AppLanguage {
        let languageCode =
            Locale.preferredLanguages.first?
                .lowercased() ?? "en"

        if languageCode.hasPrefix("th") {
            return .thai
        } else {
            return .english
        }
    }

    case english
    case thai
}


// MARK: - Localized Text

extension AppLanguage {

    var report: String {
        switch self {
        case .english:
            return "Report                                                                                                                    "
        case .thai:
            return "รายงาน                                                                                                                    "
        }
    }

    var noReports: String {
        switch self {
        case .english:
            return "No Reports"
        case .thai:
            return "ยังไม่มีรายงาน"
        }
    }

    var noReportsDescription: String {
        switch self {
        case .english:
            return "There are no reported incidents yet."
        case .thai:
            return "ยังไม่มีเหตุการณ์ที่ถูกรายงาน"
        }
    }

    var loading: String {
        switch self {
        case .english:
            return "Loading..."
        case .thai:
            return "กำลังโหลด..."
        }
    }

    var edit: String {
        switch self {
        case .english:
            return "Edit"
        case .thai:
            return "แก้ไข"
        }
    }

    var done: String {
        switch self {
        case .english:
            return "Done"
        case .thai:
            return "เสร็จสิ้น"
        }
    }

    var delete: String {
        switch self {
        case .english:
            return "Delete"
        case .thai:
            return "ลบ"
        }
    }

    var cancel: String {
        switch self {
        case .english:
            return "Cancel"
        case .thai:
            return "ยกเลิก"
        }
    }

    var deleteReport: String {
        switch self {
        case .english:
            return "Delete Report?"
        case .thai:
            return "ลบรายงาน?"
        }
    }

    var deleteReportMessage: String {
        switch self {
        case .english:
            return "Are you sure you want to delete the selected reports?"
        case .thai:
            return "คุณต้องการลบรายงานที่เลือกใช่หรือไม่?"
        }
    }

    var createEvent: String {
        switch self {
        case .english:
            return "Create Event"
        case .thai:
            return "สร้าง Event"
        }
    }

    var eventInformation: String {
        switch self {
        case .english:
            return "Event Information"
        case .thai:
            return "ข้อมูลเหตุการณ์"
        }
    }

    var eventName: String {
        switch self {
        case .english:
            return "Event Name"
        case .thai:
            return "ชื่อเหตุการณ์"
        }
    }

    var description: String {
        switch self {
        case .english:
            return "Description"
        case .thai:
            return "รายละเอียด"
        }
    }

    var type: String {
        switch self {
        case .english:
            return "Type"
        case .thai:
            return "ประเภท"
        }
    }

    var severity: String {
        switch self {
        case .english:
            return "Severity"
        case .thai:
            return "ระดับความรุนแรง"
        }
    }

    var location: String {
        switch self {
        case .english:
            return "Location"
        case .thai:
            return "ตำแหน่ง"
        }
    }

    var latitude: String {
        switch self {
        case .english:
            return "Latitude"
        case .thai:
            return "ละติจูด"
        }
    }

    var longitude: String {
        switch self {
        case .english:
            return "Longitude"
        case .thai:
            return "ลองจิจูด"
        }
    }

    var searchingLocation: String {
        switch self {
        case .english:
            return "Searching for location..."
        case .thai:
            return "กำลังค้นหาตำแหน่ง..."
        }
    }

    var addEvent: String {
        switch self {
        case .english:
            return "Create Event"
        case .thai:
            return "สร้าง Event"
        }
    }

    var locationUnavailable: String {
        switch self {
        case .english:
            return "Location Unavailable"
        case .thai:
            return "ไม่สามารถรับตำแหน่งได้"
        }
    }

    var locationUnavailableMessage: String {
        switch self {
        case .english:
            return "Please allow location access and wait until your location is available."
        case .thai:
            return "กรุณาอนุญาตให้แอปเข้าถึงตำแหน่ง และรอจนกว่าจะได้รับตำแหน่ง"
        }
    }

    var createEventFailed: String {
        switch self {
        case .english:
            return "Failed to Create Event"
        case .thai:
            return "สร้างเหตุการณ์ไม่สำเร็จ"
        }
    }

    var tryAgain: String {
        switch self {
        case .english:
            return "Try Again"
        case .thai:
            return "ลองอีกครั้ง"
        }
    }

    var eventCreated: String {
        switch self {
        case .english:
            return "Event created successfully."
        case .thai:
            return "สร้างเหตุการณ์สำเร็จ"
        }
    }
}


// MARK: - Disaster Type Localization

extension DisasterType {

    var localizedTitle: String {

        switch AppLanguage.current {

        case .english:

            switch self {
            case .flood:
                return "Flood"

            case .fire:
                return "Fire"

            case .landslide:
                return "Landslide"

            case .storm:
                return "Storm"

            case .earthquake:
                return "Earthquake"

            case .other:
                return "Other"
            }

        case .thai:

            switch self {
            case .flood:
                return "น้ำท่วม"

            case .fire:
                return "ไฟไหม้"

            case .landslide:
                return "ดินถล่ม"

            case .storm:
                return "พายุ"

            case .earthquake:
                return "แผ่นดินไหว"

            case .other:
                return "อื่น ๆ"
            }
        }
    }
}


// MARK: - Severity Localization

extension Severity {

    var localizedTitle: String {

        switch AppLanguage.current {

        case .english:

            switch self {
            case .low:
                return "Low"

            case .medium:
                return "Medium"

            case .high:
                return "High"

            case .critical:
                return "Critical"
            }

        case .thai:

            switch self {
            case .low:
                return "ต่ำ"

            case .medium:
                return "ปานกลาง"

            case .high:
                return "สูง"

            case .critical:
                return "วิกฤต"
            }
        }
    }
}


// MARK: - Report View

struct ReportView: View {

    @StateObject private var viewModel: ReportViewModel

    init(usePreviewData: Bool = false, viewModel: ReportViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ReportViewModel(usePreviewData: usePreviewData))
    }

    @State private var showDeletionError = false

    @State private var showCreateEvent = false

    @State private var isEditing = false

    @State private var selectedEventIDs: Set<String> = []

    @State private var showDeleteAlert = false


    private var language: AppLanguage {
        AppLanguage.current
    }

    var body: some View {

        NavigationStack {

            Group {

                // MARK: Loading

                if viewModel.isLoading {

                    ProgressView(language.loading)
                }

                // MARK: Empty

                else if viewModel.events.isEmpty && viewModel.errorMessage != nil {
                    Color.clear.frame(height: 1)
                }
                else if viewModel.events.isEmpty {

                    ContentUnavailableView(
                        language.noReports,
                        systemImage: "exclamationmark.triangle",
                        description: Text(
                            language.noReportsDescription
                        )
                    )
                }

                // MARK: Events

                else {

                    List(viewModel.events) { event in

                        HStack(spacing: 12) {

                            // Selection Circle

                            if isEditing {

                                Image(
                                    systemName:
                                        selectedEventIDs.contains(event.id)
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .font(.system(size: 22))
                                .foregroundStyle(
                                    selectedEventIDs.contains(event.id)
                                    ? .blue
                                    : .secondary
                                )
                            }

                            ReportRow(event: event)
                        }

                        .contentShape(Rectangle())

                        .onTapGesture {

                            guard isEditing else {
                                return
                            }

                            if selectedEventIDs.contains(event.id) {

                                selectedEventIDs.remove(event.id)

                            } else {

                                selectedEventIDs.insert(event.id)
                            }
                        }

                        .listRowSeparator(.hidden)

                        .listRowBackground(Color.clear)

                        .listRowInsets(
                            EdgeInsets(
                                top: 0,
                                leading: 20,
                                bottom: 0,
                                trailing: 0
                            )
                        )
                    }

                    .listStyle(.plain)

                    .scrollContentBackground(.hidden)

                    .contentMargins(
                        .top,
                        0,
                        for: .scrollContent
                    )
                }
            }

            .disabled(viewModel.isDeleting)
            .safeAreaInset(edge: .top) {
                EventLoadStatusView(viewModel: viewModel)
            }
            .alert(language.deletionFailed, isPresented: $showDeletionError) {
                Button(language.done, role: .cancel) {}
            } message: {
                Text(viewModel.deletionErrorMessage ?? language.deletionFailed)
            }

            // MARK: Navigation

            .navigationTitle("")

            .navigationBarTitleDisplayMode(.inline)

            // MARK: Toolbar

            .toolbar {

                ToolbarItem(placement: .title) {

                    CustomNavigationtitle(
                        title: language.report
                    )
                }

                // Add

                ToolbarItem(placement: .topBarTrailing) {

                    if !isEditing {

                        Button {

                            guard !viewModel.isDeleting else { return }
                            showCreateEvent = true

                        } label: {

                            Image(systemName: "plus")
                        }
                    }
                }
                // Edit / Done

                ToolbarItem(placement: .topBarTrailing) {

                    Button(
                        isEditing
                        ? language.done
                        : language.edit
                    ) {

                        guard !viewModel.isDeleting else { return }
                        isEditing.toggle()

                        if !isEditing {
                            selectedEventIDs.removeAll()
                        }
                    }
                }

                // Delete

                ToolbarItem(placement: .topBarTrailing) {

                    if isEditing {

                        Button(
                            role: .destructive
                        ) {

                            showDeleteAlert = true

                        } label: {

                            Image(systemName: "trash")
                        }
                        .disabled(
                            selectedEventIDs.isEmpty || viewModel.isDeleting
                        )
                    }
                }
            }

            // MARK: Delete Alert

            .alert(
                language.deleteReport,
                isPresented: $showDeleteAlert
            ) {

                Button(
                    language.delete,
                    role: .destructive
                ) {

                    Task {
                        await deleteSelectedEvents()
                    }
                }

                Button(
                    language.cancel,
                    role: .cancel
                ) {}

            } message: {

                Text(language.deleteReportMessage)
            }

            // MARK: Create Event Sheet

            .sheet(
                isPresented: $showCreateEvent
            ) {

                CreateEventView { event in
                    viewModel.recordCreatedEvent(event)
                }
            }

            // MARK: Refresh After Sheet Closes

            .onChange(of: showCreateEvent) { _, isPresented in

                if !isPresented {

                    Task {
                        await viewModel.fetchEvents()
                    }
                }
            }

            // MARK: Initial Load

            .task {

                await viewModel.fetchEvents()
            }

            // MARK: Pull To Refresh

            .refreshable {

                await viewModel.fetchEvents()
            }
        }
    }

    // MARK: - Delete Selected Events

    private func deleteSelectedEvents() async {
        guard !viewModel.isDeleting else { return }
        let visibleIDs = Set(viewModel.events.map(\.id))
        selectedEventIDs = await viewModel.deleteEvents(ids: selectedEventIDs.intersection(visibleIDs))
        if selectedEventIDs.isEmpty {
            isEditing = false
        } else {
            showDeletionError = true
        }
    }

    // MARK: - Navigation Title

    struct CustomNavigationtitle: View {

        let title: String

        var body: some View {

            Text(title)
                .font(.system(size: 28))
                .fontWeight(.bold)
        }
    }
}


// MARK: - Report Row

struct ReportRow: View {

    let event: DisasterEvent

    var body: some View {

        HStack(spacing: 0) {

            Text(eventEmoji)
                .font(.system(size: 35))
                .frame(
                    width: 70,
                    height: 70
                )
                .background(
                    Color(
                        UIColor { trait in
                            trait.userInterfaceStyle == .dark
                                ? UIColor.white.withAlphaComponent(0.13)
                                : UIColor.black.withAlphaComponent(0.07)
                        }
                    ),
                    in: RoundedRectangle(
                        cornerRadius: 50
                    )
                )
            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text(event.title)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(event.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 6) {

                    Text(
                        event.type.localizedTitle
                    )

                    Text("•")

                    Text(
                        event.severity.localizedTitle
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.leading, 12)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var eventEmoji: String {

        switch event.type {

        case .flood:
            return "🌊"

        case .fire:
            return "🔥"

        case .landslide:
            return "⛰️"

        case .storm:
            return "🌪️"

        case .earthquake:
            return "🌎"

        case .other:
            return "⚠️"
        }
    }
}


// MARK: - Create Event

struct CreateEventView: View {
    var onCreated: (DisasterEvent) -> Void = { _ in }

    @Environment(\.dismiss)
    private var dismiss

    @State private var title = ""

    @State private var description = ""

    @State private var type: DisasterType = .flood

    @State private var severity: Severity = .medium

    @StateObject
    private var locationManager = LocationManager()

    @State private var isSaving = false

    @State private var showErrorAlert = false

    @State private var errorMessage = ""

    private let firebase = FirebaseService()

    private var language: AppLanguage {
        AppLanguage.current
    }

    var body: some View {

        NavigationStack {

            Form {

                // MARK: Event Information

                Section(
                    language.eventInformation
                ) {

                    TextField(
                        language.eventName,
                        text: $title
                    )

                    TextField(
                        language.description,
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    Picker(
                        language.type,
                        selection: $type
                    ) {

                        ForEach(
                            DisasterType.allCases,
                            id: \.self
                        ) { type in

                            Text(
                                type.localizedTitle
                            )
                            .tag(type)
                        }
                    }

                    Picker(
                        language.severity,
                        selection: $severity
                    ) {

                        ForEach(
                            Severity.allCases,
                            id: \.self
                        ) { severity in

                            Text(
                                severity.localizedTitle
                            )
                            .tag(severity)
                        }
                    }
                }

                // MARK: Location

                Section(
                    language.location
                ) {

                    if let location =
                        locationManager.location {

                        HStack {

                            Text(language.latitude)

                            Spacer()

                            Text(
                                String(
                                    format: "%.6f",
                                    location.coordinate.latitude
                                )
                            )
                            .foregroundStyle(.secondary)
                        }

                        HStack {

                            Text(language.longitude)

                            Spacer()

                            Text(
                                String(
                                    format: "%.6f",
                                    location.coordinate.longitude
                                )
                            )
                            .foregroundStyle(.secondary)
                        }

                    } else {

                        HStack {

                            ProgressView()

                            Text(
                                language.searchingLocation
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                // MARK: Create Button

                Section {

                    Button {

                        Task {
                            await saveEvent()
                        }

                    } label: {

                        HStack {

                            Spacer()

                            if isSaving {

                                ProgressView()

                            } else {

                                Image(
                                    systemName:
                                        "plus.circle.fill"
                                )

                                Text(
                                    language.addEvent
                                )
                                .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(
                        title
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        description
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                        ||
                        locationManager.location == nil
                        ||
                        isSaving
                    )
                }
            }

            // MARK: Navigation

            .navigationTitle(
                language.createEvent
            )

            .navigationBarTitleDisplayMode(.inline)

            // MARK: Toolbar

            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button(
                        language.cancel
                    ) {

                        dismiss()
                    }
                }
            }

            // MARK: Location Permission

            .onAppear {

                locationManager.requestPermission()

                locationManager.startUpdatingLocation()
            }

            // MARK: Error Alert

            .alert(
                language.createEventFailed,
                isPresented: $showErrorAlert
            ) {

                Button(
                    language.tryAgain,
                    role: .cancel
                ) {}

            } message: {

                Text(errorMessage)
            }
        }
    }

    // MARK: - Save Event

    private func saveEvent() async {
        guard !isSaving else { return }

        let trimmedTitle =
            title.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let trimmedDescription =
            description.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedTitle.isEmpty else {

            showError(
                language.eventName
            )

            return
        }

        guard !trimmedDescription.isEmpty else {

            showError(
                language.description
            )

            return
        }

        guard let location =
            locationManager.location
        else {

            showError(
                language.locationUnavailableMessage
            )

            return
        }

        isSaving = true

        let latitude =
            location.coordinate.latitude

        let longitude =
            location.coordinate.longitude


        do {

            let event = try await firebase.addEvent(

                title: trimmedTitle,

                description: trimmedDescription,

                type: type,

                severity: severity,

                latitude: latitude,

                longitude: longitude
            )

            onCreated(event)

            isSaving = false

            dismiss()

        } catch {

            print(
                "❌ Failed to create event:",
                error.localizedDescription
            )

            isSaving = false

            showError(
                error.localizedDescription
            )
        }
    }

    // MARK: - Show Error

    @MainActor
    private func showError(
        _ message: String
    ) {

        errorMessage = message

        showErrorAlert = true
    }
}


// MARK: - Preview

#Preview {

    ReportView()
}
