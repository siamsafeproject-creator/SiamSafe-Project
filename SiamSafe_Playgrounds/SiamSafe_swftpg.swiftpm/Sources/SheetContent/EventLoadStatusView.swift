import SwiftUI

/// Keeps cached content usable while making a failed refresh visible.
struct EventLoadStatusView: View {
    @ObservedObject var viewModel: ReportViewModel
    var showsActive = true
    var showsResolved = false

    private var message: String? {
        if showsActive, let error = viewModel.errorMessage { return error }
        if showsResolved, let error = viewModel.resolvedErrorMessage { return error }
        return nil
    }

    var body: some View {
        if let message {
            VStack(alignment: .leading, spacing: 8) {
                Label(AppLanguage.current.eventsLoadFailed, systemImage: "wifi.exclamationmark")
                    .font(.headline)
                Text(message).font(.caption).textSelection(.enabled)
                Button(AppLanguage.current.tryAgain) {
                    Task {
                        if showsActive { await viewModel.fetchEvents() }
                        if showsResolved { await viewModel.fetchResolvedEvents() }
                    }
                }
                .disabled((showsActive && viewModel.isLoading)
                          || (showsResolved && viewModel.isLoadingResolved))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            .accessibilityElement(children: .contain)
        }
    }
}

extension AppLanguage {
    var eventsLoadFailed: String {
        self == .thai ? "โหลดเหตุการณ์ไม่สำเร็จ" : "Unable to load events"
    }
    var deletionFailed: String {
        self == .thai ? "ลบบางรายการไม่สำเร็จ กรุณาลองอีกครั้ง" : "Some reports could not be deleted. Please retry."
    }
    var alertsTitle: String {
        self == .thai ? "การแจ้งเตือน                                                                                                                                           " : "Alerts                                                                                                                                          "
    }
    var alertsEmpty: String {
        self == .thai ? "ไม่มีเหตุการณ์เร่งด่วน" : "No urgent events"
    }
    var alertsDescription: String {
        self == .thai ? "แสดงเหตุการณ์ระดับสูงและวิกฤตที่ยังดำเนินอยู่" : "Active high and critical severity events appear here."
    }
}
