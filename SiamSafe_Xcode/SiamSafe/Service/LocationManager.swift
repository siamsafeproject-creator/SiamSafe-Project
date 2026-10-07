import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var location: CLLocation?

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private var isRunningInPreview: Bool {
        RuntimeEnvironment.usesMockServices
    }

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Request Permission

    func requestPermission() {
        guard !isRunningInPreview else { return }
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - Start Location

    func startUpdatingLocation() {
        guard !isRunningInPreview else { return }
        manager.startUpdatingLocation()
    }

    // MARK: - Location Updated

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard !isRunningInPreview else { return }
        guard let newLocation = locations.last else {
            return
        }

        DispatchQueue.main.async {
            self.location = newLocation
        }
    }

    // MARK: - Authorization

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        guard !isRunningInPreview else { return }
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }

        switch manager.authorizationStatus {

        case .authorizedWhenInUse,
             .authorizedAlways:

            manager.startUpdatingLocation()

        case .denied,
             .restricted:

            print("Location permission denied")

        case .notDetermined:

            break

        @unknown default:

            break
        }
    }
}
