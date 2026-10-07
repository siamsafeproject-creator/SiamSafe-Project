import SwiftUI

struct OverView: View {

    @StateObject private var viewModel: ReportViewModel

    init(usePreviewData: Bool = false, viewModel: ReportViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ReportViewModel(usePreviewData: usePreviewData)
        )
    }

    // Card ที่เลือก
    // เริ่มต้น = ทั้งหมด
    @State private var selectedCard = "eventCount"

    // MARK: - Language

    private var language: AppLanguage {
        AppLanguage.current
    }

    // MARK: - Filtered Events

    private var filteredEvents: [DisasterEvent] {

        switch selectedCard {

        case "urgentEventCount":

            // High + Critical
            return viewModel.events.filter {
                $0.severity == .high ||
                $0.severity == .critical
            }

        default:

            // ทั้งหมด
            return viewModel.events
        }
    }
    
    struct CustomNavigationtitle: View {
        var title: LocalizedStringKey
        
        var body: some View {
            Text(title)
                .font(.system(size: 28))
                .fontWeight(.bold)
        }
    }


    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    // MARK: - Summary Cards

                    HStack(spacing: 12) {

                        SummaryCard(
                            title: language.all,
                            subtitle: language.allEventsSubtitle,
                            value: viewModel.eventCount,
                            totalValue: viewModel.eventCount,
                            valueCard: "eventCount",
                            symbol: "app.grid.2x2.fill",
                            color: .blue,
                            isSelected:
                                selectedCard == "eventCount"
                        ) {
                            selectedCard = "eventCount"
                        }

                        SummaryCard(
                            title: language.urgent,
                            subtitle: language.urgentEventsSubtitle,
                            value: viewModel.urgentEventCount,
                            totalValue: viewModel.eventCount,
                            valueCard: "urgentEventCount",
                            symbol: "exclamationmark.circle.fill",
                            color: .red,
                            isSelected:
                                selectedCard == "urgentEventCount"
                        ) {
                            selectedCard = "urgentEventCount"
                        }
                    }

                    // MARK: - Loading

                    if viewModel.isLoading &&
                        viewModel.events.isEmpty {

                        ProgressView()
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 120
                            )

                    // MARK: - Error

                    } else if viewModel.errorMessage != nil,
                              viewModel.events.isEmpty {
                        EmptyView()

                    // MARK: - No Events

                    } else if filteredEvents.isEmpty {

                        ContentUnavailableView(
                            selectedCard == "urgentEventCount"
                            ? language.noUrgentEvents
                            : language.noEvents,
                            systemImage:
                                "checkmark.circle",
                            description:
                                Text(
                                    selectedCard ==
                                    "urgentEventCount"
                                    ? language.noUrgentEventsDescription
                                    : language.noEventsDescription
                                )
                        )

                    // MARK: - Events

                    } else {

                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {

                            Text(language.reportedEvents)
                                .font(.headline)

                            ForEach(
                                filteredEvents.prefix(3)
                            ) { event in

                                OverviewEventRow(
                                    event: event
                                ) {

                                    // ส่ง Event ไปให้ Map
                                    NotificationCenter.default.post(
                                        name: .focusMapOnEvent,
                                        object: event
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .top) {
                EventLoadStatusView(viewModel: viewModel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .title) {
                    CustomNavigationtitle(
                        title: LocalizedStringKey(language.overViewTitle)
                    )
                }
            }

            // MARK: - Load Firebase

            .task {
                await viewModel.fetchEvents()
            }

            // MARK: - Refresh

            .refreshable {
                await viewModel.fetchEvents()
            }
        }
    }

    // MARK: - Summary Card

    private struct SummaryCard: View {

        let title: String
        let subtitle: String
        let value: Int
        let totalValue: Int
        let valueCard: String
        let symbol: String
        let color: Color
        let isSelected: Bool
        let action: () -> Void

        var body: some View {

            Button {
                action()
            } label: {

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    // Header

                    HStack {

                        Image(systemName: symbol)
                            .font(.title)
                            .foregroundStyle(color)

                        Text(title)
                            .foregroundStyle(color)
                    }

                    // Value

                    HStack(
                        alignment: .center,
                        spacing: 4
                    ) {

                        Text("\(value)")
                            .font(.system(size: 60))
                            .fontWeight(.bold)

                        if valueCard ==
                            "urgentEventCount" {

                            Text("/\(totalValue)")
                                .font(.title2)
                                .foregroundStyle(
                                    .secondary
                                )
                        }
                    }

                    // Subtitle

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            .primary.opacity(0.75)
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()

                // Background

                .background(
                    color.opacity(0.25),
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                // Selection outline

                .overlay {

                    RoundedRectangle(
                        cornerRadius: 16
                    )
                    .stroke(
                        isSelected
                        ? color
                        : .clear,
                        lineWidth: 3
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Event Row

    private struct OverviewEventRow: View {

        let event: DisasterEvent
        let action: () -> Void

        var body: some View {

            Button {
                action()
            } label: {

                HStack(spacing: 12) {

                    // Emoji

                    Text(emoji)
                        .font(.title2)
                        .frame(
                            width: 42,
                            height: 42
                        )
                        .background(
                            .thinMaterial,
                            in: Circle()
                        )

                    // Event Information

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text(event.title)
                            .fontWeight(.semibold)

                        Text(
                            event.type.localizedTitle
                            + " • "
                            + event.severity.localizedTitle
                        )
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    .background,
                    in: RoundedRectangle(
                        cornerRadius: 14
                    )
                )
                .overlay {

                    RoundedRectangle(
                        cornerRadius: 14
                    )
                    .stroke(
                        .separator.opacity(0.5),
                        lineWidth: 1
                    )
                }
            }
            .buttonStyle(.plain)
        }

        // MARK: - Emoji

        private var emoji: String {

            switch event.type {

            case .flood:
                "🌊"

            case .fire:
                "🔥"

            case .landslide:
                "⛰️"

            case .storm:
                "🌪️"

            case .earthquake:
                "🌎"

            case .other:
                "⚠️"
            }
        }
    }
}

// MARK: - Map Notification

extension Notification.Name {

    static let focusMapOnEvent =
        Notification.Name("focusMapOnEvent")
}

// MARK: - Overview Language

extension AppLanguage {
    
    var overViewTitle: String {
        switch self {
        case .english:
            return "Overview                                                                                                    "
        case .thai:
            return "ภาพรวม                                                                                                      "
        }
        
    }

    var all: String {

        switch self {

        case .english:
            return "All"

        case .thai:
            return "ทั้งหมด"
        }
    }

    var urgent: String {

        switch self {

        case .english:
            return "Urgent"

        case .thai:
            return "ต้องติดตาม"
        }
    }

    var allEventsSubtitle: String {

        switch self {

        case .english:
            return "Currently reported events"

        case .thai:
            return "เหตุการณ์ที่กำลังรายงาน"
        }
    }

    var urgentEventsSubtitle: String {

        switch self {

        case .english:
            return "High and critical risk"

        case .thai:
            return "รุนแรงและเสี่ยงสูง"
        }
    }

    var reportedEvents: String {

        switch self {

        case .english:
            return "Reported Events"

        case .thai:
            return "เหตุการณ์ที่กำลังรายงาน"
        }
    }

    var loadFailed: String {

        switch self {

        case .english:
            return "Failed to load data"

        case .thai:
            return "โหลดข้อมูลไม่สำเร็จ"
        }
    }

    var noEvents: String {

        switch self {

        case .english:
            return "No Events"

        case .thai:
            return "ยังไม่มีเหตุการณ์"
        }
    }

    var noEventsDescription: String {

        switch self {

        case .english:
            return "Events from Firebase will appear here"

        case .thai:
            return "เมื่อมีรายการจาก Firebase จะแสดงที่นี่"
        }
    }

    var noUrgentEvents: String {

        switch self {

        case .english:
            return "No Urgent Events"

        case .thai:
            return "ไม่มีเหตุการณ์ที่ต้องติดตาม"
        }
    }

    var noUrgentEventsDescription: String {

        switch self {

        case .english:
            return "There are no High or Critical events"

        case .thai:
            return "ยังไม่มีเหตุการณ์ระดับ High หรือ Critical"
        }
    }
}

#Preview {
    OverView()
}
