import SwiftUI
import CoreLocation

extension DisasterEvent {

    func distance(from location: CLLocation) -> CLLocationDistance {

        let eventLocation = CLLocation(
            latitude: latitude,
            longitude: longitude
        )

        return location.distance(from: eventLocation)
    }

    func distanceText(from location: CLLocation) -> String {

        let distance = distance(from: location)

        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
}

struct EventDetailView: View {

    let event: DisasterEvent

    @StateObject private var locationManager = LocationManager()

    @Environment(\.dismiss) private var dismiss

    private var language: AppLanguage {
        AppLanguage.current
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Header

                    HStack(spacing: 14) {

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

                        VStack(alignment: .leading, spacing: 4) {

                            Text(event.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text(event.type.localizedTitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    // MARK: - Severity

                    VStack(alignment: .leading, spacing: 8) {

                        Text(language.severity)
                            .font(.headline)

                        HStack {
                            Text(event.severity.localizedTitle)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(severityColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            severityColor.opacity(0.12),
                            in: Capsule()
                        )
                    }

                    // MARK: - Description

                    VStack(alignment: .leading, spacing: 8) {

                        Text(language.description)
                            .font(.headline)

                        Text(event.description)
                            .foregroundStyle(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    }

                    // MARK: - Location

                    VStack(alignment: .leading, spacing: 8) {

                        Text(language.location)
                            .font(.headline)

                        HStack(spacing: 8) {

                            Image(systemName: "location.fill")
                                .foregroundStyle(.red.opacity(0.75))

                            Text(
                                "\(event.latitude, specifier: "%.5f"), \(event.longitude, specifier: "%.5f")"
                            )
                            .foregroundStyle(.secondary)
                        }
                    }

                    // MARK: - Distance

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Distance")
                            .font(.headline)

                        if let userLocation = locationManager.location {

                            HStack(spacing: 8) {

                                Image(systemName: "location.fill")
                                    .foregroundStyle(.red.opacity(0.75))

                                Text(
                                    event.distanceText(
                                        from: userLocation
                                    )
                                )
                                .fontWeight(.semibold)
                            }
                            .foregroundStyle(.secondary)

                        } else {

                            HStack(spacing: 8) {

                                ProgressView()

                                Text("Calculating...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: - Created At

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Reported At")
                            .font(.headline)

                        Text(
                            event.createdAt.formatted(
                                date: .abbreviated,
                                time: .shortened
                            )
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(language.done) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            locationManager.requestPermission()
        }
    }

    // MARK: - Event Emoji

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

    // MARK: - Event Color

    private var eventColor: Color {
        switch event.type {
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

    // MARK: - Severity Color

    private var severityColor: Color {
        switch event.severity {
        case .low:
            return .green

        case .medium:
            return .yellow

        case .high:
            return .orange

        case .critical:
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    EventDetailView(
        event: DisasterEvent(
            id: "preview-event",
            title: "Flood in Bangna",
            description: "Flooding has been reported in the surrounding area.",
            type: .flood,
            severity: .high,
            latitude: 13.6467,
            longitude: 100.6800,
            createdAt: Date(),
            status: "active"
        )
    )
}
