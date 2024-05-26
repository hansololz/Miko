import Foundation
import CoreLocation

func saveLocationInSearchQueryPreference(preference: Bool) {
    UserDefaults.standard.set(preference, forKey: "locationInSearchQuery")
}

func loadLocationInSearchQueryPreference() -> Bool {
    return UserDefaults.standard.bool(forKey: "locationInSearchQuery")
}

// LocationManager Class
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var lastUpdateTime: Date?

    @Published var location: CLLocation? {
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
        print("Started Query")
        lastLocation = nil
        lastUpdateTime = nil
        locationName = ""
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stopped Query")
        lastLocation = nil
        lastUpdateTime = nil
        locationName = ""
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        self.location = newLocation
    }
    
    func isAuthorized() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .fullAccuracy
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Error in reverse geocoding: \(error)")
                self.locationName = ""
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                if self.locationName != placemark.name ?? "" {
                    self.locationName = placemark.name ?? ""
                    print("NEW LOCATION \(self.locationName)")
                }
                
                print("OLD LOCATION \(self.locationName)")
            }
        }
    }
}

// LocationViewModel Class
class LocationViewModel: ObservableObject {
    @Published var locationName: String = "Fetching location..."
    private var locationManager = LocationManager()
    
    init() {
        locationManager.$locationName
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationName)
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}
