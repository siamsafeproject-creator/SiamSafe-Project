import SwiftUI

struct AlertsView: View {
    @ObservedObject var viewModel: ReportViewModel
    private var language: AppLanguage { .current }

    struct CustomNavigationTitle: View {
        let title: String

        var body: some View {
            Text(title)
                .font(.system(size: 28))
                .fontWeight(.bold)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    EventLoadStatusView(viewModel: viewModel)
                    if viewModel.isLoading && viewModel.events.isEmpty {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 120)
                    } else if viewModel.urgentEvents.isEmpty && viewModel.errorMessage == nil {
                        ContentUnavailableView(
                            language.alertsEmpty,
                            systemImage: "checkmark.shield",
                            description: Text(language.alertsDescription)
                        )
                    } else {
                        ForEach(viewModel.urgentEvents) { event in
                            Button {
                                NotificationCenter.default.post(name: .focusMapOnEvent, object: event)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(event.severity == .critical ? .red : .orange)
                                        .font(.title)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title).font(.headline)
                                        Text("\(event.type.localizedTitle) · \(event.severity.localizedTitle)")
                                            .font(.subheadline).foregroundStyle(.secondary)
                                        Text(event.createdAt, style: .relative)
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(
                                    .background,
                                    in: RoundedRectangle(cornerRadius: 14)
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
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    CustomNavigationTitle(title: language.alertsTitle)
                }
            }
            .task { await viewModel.fetchEvents() }
            .refreshable { await viewModel.fetchEvents() }
        }
    }
}

