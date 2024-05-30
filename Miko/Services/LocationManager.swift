import Foundation
import CoreLocation

func saveLocationInSearchQueryPreference(preference: Bool) {
    UserDefaults.standard.set(preference, forKey: "locationInSearchQuery")
}

func loadLocationInSearchQueryPreference() -> Bool {
    return UserDefaults.standard.bool(forKey: "locationInSearchQuery")
}

func saveIsFirstEverLocationPermissionRequest() {
    UserDefaults.standard.set(false, forKey: "isFirstEverLocationPermissionRequest")
}

func loadIsFirstEverLocationPermissionRequest() -> Bool {
    let userDefaults = UserDefaults.standard
    if userDefaults.object(forKey: "isFirstEverLocationPermissionRequest") == nil {
        return true
    } else {
        return userDefaults.bool(forKey: "isFirstEverLocationPermissionRequest")
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var lastUpdateTime: Date?
    private var authorizedCallback: (() -> Void)?
    private var location: CLLocation? {
        didSet {
            if let location = location {
                fetchLocationName(from: location)
            }
        }
    }
    
    @Published var locationName: String = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }
    
    func startUpdatingLocation() {
        print("GEO LOCATION START")
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("GEO LOCATION STOP")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        self.location = newLocation
    }
    
    func isAuthorized() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .fullAccuracy
    }
    
    func requestAuthorization(callback: @escaping () -> Void) {
        self.authorizedCallback = callback
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location permission granted.")
        case .denied, .restricted:
            print("Location permission denied or restricted.")
        case .notDetermined:
            print("Location permission not determined.")
        @unknown default:
            print("Unknown authorization status.")
        }
        
        authorizedCallback?()
    }
    
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Error in reverse geocoding: \(error)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                let newLocationName: String
                if let areaOfInterest = placemark.areasOfInterest?.first, !areaOfInterest.isEmpty {
                    newLocationName = areaOfInterest
                } else {
                    if placemark.name != nil && placemark.locality != nil {
                        newLocationName = "\(placemark.name ?? ""), \(placemark.locality ?? "")"
                    } else if placemark.name != nil {
                        newLocationName = placemark.name ?? ""
                    } else if placemark.locality != nil {
                        newLocationName = placemark.locality ?? ""
                    } else {
                        newLocationName = ""
                    }
                }
                
                if self.locationName != newLocationName && !newLocationName.isEmpty {
                    self.locationName = newLocationName
                }
            }
        }
    }
}
