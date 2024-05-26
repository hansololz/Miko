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
    
    @Published var location: CLLocation? {
        didSet {
            if let location = location {
                fetchLocationName(from: location)
            }
        }
    }
    @Published var locationName: String = "Unknown"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func fetchLocationName(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("Error in reverse geocoding: \(error)")
                self.locationName = "Unknown"
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                self.locationName = placemark.locality ?? "Unknown"
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
