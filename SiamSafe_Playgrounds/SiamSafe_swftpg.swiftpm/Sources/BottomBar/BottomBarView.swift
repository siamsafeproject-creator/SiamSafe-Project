import SwiftUI

//// TabEnum
enum AppTab: String, CaseIterable {
    case overview = "Overview"
    case map = "Map"
    case alerts = "Alerts"
    case report = "Report"
    
    var symbolImage: String {
        switch self {
        case .overview:
            return "circle.grid.2x2.fill"
        case .map:
            return "location.fill.viewfinder"
        case .alerts:
            return "aqi.high"
        case .report:
        return "exclamationmark.bubble.fill"
        }
    }
}


struct BottomBarView: View {
    private let usePreviewData: Bool
    @StateObject private var viewModel: ReportViewModel
    @State private var activeTab: AppTab = .overview
    @State private var selectedEvent: DisasterEvent?
    private let onTabChange: () -> Void

    init(usePreviewData: Bool = false, viewModel: ReportViewModel? = nil, onTabChange: @escaping () -> Void = {}) {
        self.usePreviewData = usePreviewData
        self.onTabChange = onTabChange
        _viewModel = StateObject(wrappedValue: viewModel ?? ReportViewModel(usePreviewData: usePreviewData))
    }

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                switch activeTab {

                case .overview:
                    OverView(usePreviewData: usePreviewData, viewModel: viewModel)
                        .transition(.opacity)

                case .map:
                    MapView(usePreviewData: usePreviewData, viewModel: viewModel)
                        .transition(.opacity)

                case .alerts:
                    AlertsView(viewModel: viewModel)
                        .transition(.opacity)

                case .report:
                    ReportView(usePreviewData: usePreviewData, viewModel: viewModel)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: activeTab)
                        
            CustomTabBar()
        }
        .animation(.smooth, value: activeTab)
        .onChange(of: activeTab) { _, _ in
            onTabChange()
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusMapOnEvent)) { notification in
            selectedEvent = notification.object as? DisasterEvent
        }
        .sheet(item: $selectedEvent) { event in
            EventDetailView(event: event)
                .presentationBackgroundInteraction(.enabled)
        }
    }
    private let tabs = Array(AppTab.allCases)
    @State private var dragX: CGFloat? = nil
    
    @ViewBuilder
    func CustomTabBar() -> some View {
        GeometryReader { proxy in
            let itemWidth = max(proxy.size.width / CGFloat(tabs.count), 1)
            let maxOffset = itemWidth * CGFloat(tabs.count - 1)
            let activeIndex = CGFloat(tabs.firstIndex(of: activeTab) ?? 0)

            // ตอนลาก: ตามนิ้ว (ไม่หลุดขอบ) / ตอนไม่ลาก: อยู่ที่ tab ที่เลือก
            let capsuleX = dragX.map { min(max($0 - itemWidth / 2, 0), maxOffset) }
                            ?? activeIndex * itemWidth

            // tab ที่ capsule อยู่ใกล้ที่สุดตอนนี้ (ใช้เปลี่ยนสี icon แบบ live)
            let rawIndex = (capsuleX / itemWidth).rounded()
            let nearestIndex = rawIndex.isFinite ? Int(rawIndex) : 0
            let nearest = tabs[min(max(nearestIndex, 0), tabs.count - 1)]

            ZStack(alignment: .leading) {
                // indicator ที่สไลด์
                Capsule()
                    .fill(Color(UIColor { trait in
                        trait.userInterfaceStyle == .dark
                            ? UIColor.white.withAlphaComponent(0.13)
                            : UIColor.black.withAlphaComponent(0.07)
                    }))
                    .frame(width: itemWidth)
                    .offset(x: capsuleX)

                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        VStack(spacing: 1) {
                            Image(systemName: tab.symbolImage)
                                .font(.title2)
                            Text(tab.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(nearest == tab ? .blue : .primary.opacity(0.75))
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .geometryGroup()
            .animation(.snappy(duration: 0.3), value: activeTab)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = value.location.x

                        if dragX == nil {
                            // แตะเฉยๆ (ยังไม่ขยับเกิน 6pt) → ยังไม่ทำอะไร
                            guard abs(value.translation.width) > 6 else { return }
                            // เริ่มตามนิ้วครั้งแรก → สไลด์ไปหานิ้วแบบสั้นๆ ไม่ให้กระโดด
                            withAnimation(.snappy(duration: 0.15)) {
                                dragX = x
                            }
                        } else {
                            // ตามนิ้วทันที ปิด animation
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                dragX = x
                            }
                        }
                    }
                    .onEnded { value in
                        let i = min(max(Int(value.location.x / itemWidth), 0), tabs.count - 1)
                        withAnimation(.snappy(duration: 0.3)) {
                            activeTab = tabs[i]    // commit tab ตอนปล่อย / ตอนแตะ
                            dragX = nil            // capsule สไลด์เข้า slot
                        }
                    }
            )
            .sensoryFeedback(.selection, trigger: nearest)
        }
        .frame(height: 56)
        .padding(4)
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }}  ////TabBarFunc

