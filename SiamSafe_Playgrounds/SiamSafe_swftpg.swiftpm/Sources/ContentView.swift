import SwiftUI

struct ContentView: View {
    private let usePreviewData: Bool
    @StateObject private var viewModel: ReportViewModel

    @State private var showBottomBar: Bool = true
    @State private var selection: PresentationDetent = .height(93)

    init(usePreviewData: Bool = false) {
        self.usePreviewData = usePreviewData
        _viewModel = StateObject(wrappedValue: ReportViewModel(usePreviewData: usePreviewData))
    }

    var body: some View {
        MapKitsView(usePreviewData: usePreviewData, viewModel: viewModel)
            .sheet(isPresented: $showBottomBar) {
                BottomBarView(usePreviewData: usePreviewData, viewModel: viewModel) {
                    if selection == .height(93) {
                        withAnimation(.smooth) {
                            selection = .fraction(0.5)
                        }
                    }
                }
                    .presentationDetents(
                        [.height(93), .fraction(0.5), .large],
                        selection: $selection
                    )
                    .presentationBackgroundInteraction(.enabled)
                    .presentationCompactAdaptation(.none)
                    .interactiveDismissDisabled()
            }
    }
}

