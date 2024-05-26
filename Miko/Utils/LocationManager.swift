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
        
        print("HERE 1")
        
        // Check if the last update time is more than 1 minute ago
        if let lastUpdateTime = lastUpdateTime {
            print("HERE 1.1")
            let timeInterval = Date().timeIntervalSince(lastUpdateTime)
            if timeInterval < 60 {
                print("HERE 1.2")
                // Less than a minute has passed since the last update
                return
            }
        }
        
        print("HERE 2")
        
        // Update the location if it is more than 5 meters away from the last known location
        if let lastLocation = lastLocation {
            print("HERE 3")
            let distance = newLocation.distance(from: lastLocation)
            if distance > 5 {
                print("HERE 4")
                self.location = newLocation
                self.lastLocation = newLocation
            }
        } else {
            print("HERE 5")
            self.location = newLocation
            self.lastLocation = newLocation
        }
        
        self.lastUpdateTime = Date()
    }
    
    func isAuthorized() -> Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse && locationManager.accuracyAuthorization == .fullAccuracy
    }
    
//    func isTempAuthorized() -> Bool {
//        return locationManager.authorizationStatus == .
//    }
//    
    func requestAuthorization() {
//        if (locationManager.authorizationStatus != .authorizedWhenInUse) {
//            locationManager.requestWhenInUseAuthorization()
//        }
    }
    
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Error in reverse geocoding: \(error)")
                self.locationName = ""
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                self.locationName = placemark.name ?? ""
            }
            
            print("LOCATION \(self.locationName)")
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
