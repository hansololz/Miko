import Foundation
import CoreLocation

func saveLocationInSearchQueryPreference(preference: Bool) {
    UserDefaults.standard.set(preference, forKey: "locationInSearchQuery")
    print("Saved preference: \(preference)")
}

func loadLocationInSearchQueryPreference() -> Bool {
    let preference = UserDefaults.standard.bool(forKey: "locationInSearchQuery")
    print("Loaded preference: \(preference)")
    return preference
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
    }
}
