import SwiftUI
import MapKit

struct MapKitsView: View {

    private let usesPreviewData: Bool

    @StateObject private var locationManager: LocationManager

    @StateObject private var viewModel: ReportViewModel

    @State private var position: MapCameraPosition

    @State private var selectedEvent:
        DisasterEvent?

    init(usePreviewData: Bool = false, viewModel: ReportViewModel? = nil) {
        self.usesPreviewData = usePreviewData
        _locationManager = StateObject(wrappedValue: LocationManager())
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ReportViewModel(usePreviewData: usePreviewData)
        )
        _position = State(
            initialValue: usePreviewData
                ? .region(Self.previewRegion)
                : .userLocation(followsHeading: false, fallback: .automatic)
        )
    }

    private var isRunningInPreview: Bool {
        usesPreviewData || RuntimeEnvironment.usesMockServices
    }

    var body: some View {

        map
            .safeAreaInset(edge: .top) {
                EventLoadStatusView(viewModel: viewModel)
            }

            // MARK: - Event Detail Sheet

            .onChange(of: selectedEvent?.id) { _, _ in
                if let event = selectedEvent {
                    NotificationCenter.default.post(name: .focusMapOnEvent, object: event)
                    selectedEvent = nil
                }
            }

            // MARK: - Focus Event

            .onReceive(
                NotificationCenter.default.publisher(
                    for: .focusMapOnEvent
                )
            ) { notification in

                guard let event =
                    notification.object as? DisasterEvent
                else {
                    return
                }

                focusOnEvent(event)
            }
            .onChange(of: locationManager.authorizationStatus) { _, status in
                guard !isRunningInPreview else { return }

                if status == .denied || status == .restricted {
                    showSimulatedLocation()
                }
            }
    }

    // MARK: - Map

    @ViewBuilder
    private var map: some View {

        if isRunningInPreview {
            // MapKit itself can take longer than Canvas's five-second budget to
            // start.  Use a lightweight stand-in only while rendering previews;
            // the app still uses the real, interactive MapKit map at runtime.
            MapPreview(
                events: viewModel.events,
                selectedEvent: $selectedEvent,
                emoji: emoji
            )
            .onAppear {
                // `ReportViewModel` supplies local sample events in previews.
                // This remains as a fallback for previews created before it.
                loadPreviewEvents()
            }

        } else {

            Map(position: $position) {

                // User Location

                UserAnnotation()

                // Events

                ForEach(viewModel.events) { event in

                    Annotation(
                        event.title,
                        coordinate: CLLocationCoordinate2D(
                            latitude: event.latitude,
                            longitude: event.longitude
                        )
                    ) {

                        Button {

                            selectedEvent = event

                        } label: {

                            Text(
                                emoji(for: event.type)
                            )
                            .font(
                                .system(size: 38)
                            )
                            .frame(
                                width: 44,
                                height: 44
                            )
                            .background(
                                Color.white,
                                in: Circle()
                            )
                            .overlay {

                                Circle()
                                    .stroke(
                                        .white,
                                        lineWidth: 3
                                    )
                            }
                            .shadow(radius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .mapStyle(.standard)

            // MARK: - Map Controls

            .mapControls {

                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

            // MARK: - Location Permission

            .onAppear {

                locationManager
                    .requestPermission()

                if locationManager.authorizationStatus == .denied
                    || locationManager.authorizationStatus == .restricted {
                    showSimulatedLocation()
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

    // MARK: - Lightweight Canvas Map

    private struct MapPreview: View {

        let events: [DisasterEvent]
        @Binding var selectedEvent: DisasterEvent?
        let emoji: (DisasterType) -> String

        private let markerOffsets: [CGSize] = [
            CGSize(width: -88, height: 42),
            CGSize(width: 66, height: -34),
            CGSize(width: 16, height: 98)
        ]

        var body: some View {

            ZStack {
                LinearGradient(
                    colors: [.cyan.opacity(0.7), .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "map.fill")
                    .font(.system(size: 180))
                    .foregroundStyle(.white.opacity(0.16))

                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    Button {
                        selectedEvent = event
                    } label: {
                        Text(emoji(event.type))
                            .font(.system(size: 32))
                            .frame(width: 44, height: 44)
                            .background(.white, in: Circle())
                            .shadow(radius: 4)
                    }
                    .buttonStyle(.plain)
                    .offset(markerOffsets[index % markerOffsets.count])
                }
            }
            .overlay(alignment: .topLeading) {
                Label("ตำแหน่งจำลอง: กรุงเทพฯ", systemImage: "location.fill")
                    .font(.caption.weight(.semibold))
                    .padding(10)
                    .background(.thinMaterial, in: Capsule())
                    .padding()
            }
        }
    }

    // MARK: - Focus On Event

    private func focusOnEvent(
        _ event: DisasterEvent
    ) {

        let coordinate =
            CLLocationCoordinate2D(
                latitude: event.latitude,
                longitude: event.longitude
            )

        withAnimation(.easeInOut(duration: 0.8)) {

            position = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: 3000
                )
            )
        }
    }

    private func showSimulatedLocation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .region(Self.previewRegion)
        }
    }

    // MARK: - Preview Events

    private func loadPreviewEvents() {

        guard viewModel.events.isEmpty else {
            return
        }

        viewModel.events = [
            DisasterEvent(
                id: "preview-1",
                title: "น้ำท่วม",
                description: "Preview Event",
                type: .flood,
                severity: .high,
                latitude: 13.7563,
                longitude: 100.5018,
                createdAt: Date(),
                status: "active"
            ),

            DisasterEvent(
                id: "preview-2",
                title: "ไฟไหม้",
                description: "Preview Event",
                type: .fire,
                severity: .critical,
                latitude: 13.7367,
                longitude: 100.5231,
                createdAt: Date(),
                status: "active"
            )
        ]
    }

    // MARK: - Preview Region

    private var previewRegion:
        MKCoordinateRegion {
        Self.previewRegion
    }

    private static let previewRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 13.7563,
                longitude: 100.5018
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )

    // MARK: - Emoji

    private func emoji(
        for type: DisasterType
    ) -> String {

        switch type {

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

    // MARK: - Color

    private func color(
        for type: DisasterType
    ) -> Color {

        switch type {

        case .flood:
            return .blue

        case .fire:
            return .red

        case .landslide:
            return .brown

        case .storm:
            return .purple

        case .earthquake:
            return .orange

        case .other:
            return .gray
        }
    }
}

#Preview {
    MapKitsView(usePreviewData: true)
}
