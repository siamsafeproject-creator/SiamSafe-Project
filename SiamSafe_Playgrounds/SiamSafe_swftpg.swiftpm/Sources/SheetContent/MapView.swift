import SwiftUI
import CoreLocation

struct MapView: View {

    fileprivate enum StatusFilter: String, CaseIterable, Identifiable {
        case all
        case active
        case resolved

        var id: String { rawValue }
    }

    @StateObject private var viewModel: ReportViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var searchText = ""
    @State private var selectedType: DisasterType?
    @State private var selectedStatus: StatusFilter = .active
    @State private var showsOnlyUrgent = false
    @State private var sortByDistance = true

    init(usePreviewData: Bool = false, viewModel: ReportViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ReportViewModel(usePreviewData: usePreviewData)
        )
    }

    private var language: AppLanguage { AppLanguage.current }

    private var filteredEvents: [DisasterEvent] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let source = selectedStatus == .active ? viewModel.events
            : selectedStatus == .resolved ? viewModel.resolvedEvents
            : viewModel.allEvents
        let matchingEvents = source.filter { event in
            let matchesSearch = query.isEmpty
                || event.title.localizedCaseInsensitiveContains(query)
                || event.description.localizedCaseInsensitiveContains(query)
            let matchesType = selectedType == nil || event.type == selectedType
            let matchesStatus = selectedStatus == .all
                || event.status.lowercased() == selectedStatus.rawValue
            let matchesSeverity = !showsOnlyUrgent
                || event.severity == .high
                || event.severity == .critical

            return matchesSearch && matchesType && matchesStatus && matchesSeverity
        }

        return matchingEvents.sorted { lhs, rhs in
            if sortByDistance, let location = locationManager.location {
                return distance(from: location, to: lhs)
                    < distance(from: location, to: rhs)
            }

            return lhs.createdAt > rhs.createdAt
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    searchField
                    quickFilters
                    filterMenus
                    EventLoadStatusView(
                        viewModel: viewModel,
                        showsActive: selectedStatus != .resolved,
                        showsResolved: selectedStatus != .active
                    )
                    eventList
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomNavigationTitle(title: language.mapTitle)
                }
            }
            .task(id: selectedStatus) {
                await refreshEvents()
            }
            .refreshable { await refreshEvents() }
            .onAppear {
                locationManager.requestPermission()
                locationManager.startUpdatingLocation()
            }
        }
    }

    private func refreshEvents() async {
        if selectedStatus != .resolved { await viewModel.fetchEvents() }
        if selectedStatus != .active { await viewModel.fetchResolvedEvents() }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.primary)

            TextField(language.searchEvents, text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                }
                .accessibilityLabel(language.clearSearch)
            }
        }
        .padding(12)
        .background(.separator.opacity(0.65), in: RoundedRectangle(cornerRadius: 50))
    }

    private var quickFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    title: language.nearest,
                    symbol: "location.fill",
                    isSelected: sortByDistance
                ) {
                    sortByDistance.toggle()
                }

                filterChip(
                    title: language.urgent,
                    symbol: "exclamationmark.triangle.fill",
                    isSelected: showsOnlyUrgent
                ) {
                    showsOnlyUrgent.toggle()
                }

                filterChip(
                    title: language.all,
                    symbol: "square.grid.2x2",
                    isSelected: selectedType == nil && selectedStatus == .all
                ) {
                    selectedType = nil
                    selectedStatus = .all
                    showsOnlyUrgent = false
                }
            }
        }
    }

    private var filterMenus: some View {
        HStack(spacing: 12) {
            Menu {
                Button(language.allTypes) {
                    selectedType = nil
                }

                ForEach(DisasterType.allCases) { type in
                    Button(type.localizedTitle) {
                        selectedType = type
                    }
                }
            } label: {
                filterMenuLabel(
                    title: selectedType?.localizedTitle ?? language.allTypes,
                    symbol: "line.3.horizontal.decrease.circle"
                )
            }

            Menu {
                ForEach(StatusFilter.allCases) { status in
                    Button(language.statusTitle(for: status)) {
                        selectedStatus = status
                    }
                }
            } label: {
                filterMenuLabel(
                    title: language.statusTitle(for: selectedStatus),
                    symbol: "checkmark.circle"
                )
            }
        }
    }

    @ViewBuilder
    private var eventList: some View {
        let loading = (selectedStatus != .resolved && viewModel.isLoading)
            || (selectedStatus != .active && viewModel.isLoadingResolved)
        let failed = (selectedStatus != .resolved && viewModel.errorMessage != nil)
            || (selectedStatus != .active && viewModel.resolvedErrorMessage != nil)
        if loading && filteredEvents.isEmpty {
            ProgressView().frame(maxWidth: .infinity, minHeight: 120)
        } else if failed && filteredEvents.isEmpty {
            EmptyView()
        } else if filteredEvents.isEmpty {
            ContentUnavailableView(
                language.noMatchingEvents,
                systemImage: "magnifyingglass",
                description: Text(language.noMatchingEventsDescription)
            )
            .frame(maxWidth: .infinity, minHeight: 220)
        } else {
            Text(sortByDistance && locationManager.location != nil
                 ? language.nearbyEvents
                 : language.latestEvents)
                .font(.headline)

            ForEach(filteredEvents) { event in
                Button {
                    NotificationCenter.default.post(
                        name: .focusMapOnEvent,
                        object: event
                    )
                } label: {
                    EventRow(
                        event: event,
                        distanceText: distanceText(for: event)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func filterChip(
        title: String,
        symbol: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.12),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private func filterMenuLabel(title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func distance(from location: CLLocation, to event: DisasterEvent) -> CLLocationDistance {
        location.distance(
            from: CLLocation(latitude: event.latitude, longitude: event.longitude)
        )
    }

    private func distanceText(for event: DisasterEvent) -> String? {
        guard let location = locationManager.location else { return nil }

        let meters = distance(from: location, to: event)
        if meters < 1_000 {
            return String(format: "%.0f %@", meters, language.meters)
        }

        return String(format: "%.1f %@", meters / 1_000, language.kilometers)
    }
}

private struct EventRow: View {
    let event: DisasterEvent
    let distanceText: String?

    var body: some View {
        HStack(spacing: 12) {
            Text(event.type.emoji)
                .font(.title2)
                .frame(width: 42, height: 42)
                .background(.thinMaterial, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(event.type.localizedTitle) · \(event.severity.localizedTitle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let distanceText {
                    Label(distanceText, systemImage: "location")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.separator.opacity(0.45), lineWidth: 1)
        }
    }
}

private extension DisasterType {
    var emoji: String {
        switch self {
        case .flood: "🌊"
        case .fire: "🔥"
        case .landslide: "⛰️"
        case .storm: "🌪️"
        case .earthquake: "🌎"
        case .other: "⚠️"
        }
    }

}

private struct CustomNavigationTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 28))
            .fontWeight(.bold)
    }
}

private extension AppLanguage {
    var mapTitle: String {
        switch self {
        case .english: "Search Map                                                                                          "
        case .thai: "ค้นหาเเผนที่                                                                                               "
        }
    }

    var searchEvents: String {
        switch self {
        case .english: "Search events"
        case .thai: "ค้นหาชื่อหรือรายละเอียดเหตุการณ์"
        }
    }

    var clearSearch: String {
        switch self {
        case .english: "Clear search"
        case .thai: "ล้างการค้นหา"
        }
    }

    var nearest: String {
        switch self {
        case .english: "Nearest"
        case .thai: "ใกล้ฉัน"
        }
    }

    var allTypes: String {
        switch self {
        case .english: "All types"
        case .thai: "ทุกประเภท"
        }
    }

    var nearbyEvents: String {
        switch self {
        case .english: "Nearby events"
        case .thai: "เหตุการณ์ใกล้คุณ"
        }
    }

    var latestEvents: String {
        switch self {
        case .english: "Latest events"
        case .thai: "เหตุการณ์ล่าสุด"
        }
    }

    var noMatchingEvents: String {
        switch self {
        case .english: "No matching events"
        case .thai: "ไม่พบเหตุการณ์ที่ตรงกัน"
        }
    }

    var noMatchingEventsDescription: String {
        switch self {
        case .english: "Try changing your search or filters."
        case .thai: "ลองเปลี่ยนคำค้นหาหรือตัวกรอง"
        }
    }

    var meters: String {
        switch self {
        case .english: "m away"
        case .thai: "ม."
        }
    }

    var kilometers: String {
        switch self {
        case .english: "km away"
        case .thai: "กม."
        }
    }

    func statusTitle(for status: MapView.StatusFilter) -> String {
        switch (self, status) {
        case (.english, .all): "All status"
        case (.english, .active): "Active"
        case (.english, .resolved): "Resolved"
        case (.thai, .all): "ทุกสถานะ"
        case (.thai, .active): "กำลังดำเนินการ"
        case (.thai, .resolved): "แก้ไขแล้ว"
        }
    }
}

