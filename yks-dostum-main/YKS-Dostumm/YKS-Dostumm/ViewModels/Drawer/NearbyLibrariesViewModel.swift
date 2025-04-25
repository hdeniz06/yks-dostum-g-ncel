import Foundation
import CoreLocation
import MapKit
import Combine

class NearbyLibrariesViewModel: NSObject, ObservableObject {
    @Published var libraries: [Library] = []
    @Published var selectedLibrary: Library?
    @Published var userLocation: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), // Default to Istanbul
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var searchRadius: Double = 5000 // 5 km in meters
    @Published var locationStatus: LocationStatus = .unknown
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    enum LocationStatus {
        case unknown
        case denied
        case authorized
        case searching
        case found
        case error(String)
        
        var isDenied: Bool {
            if case .denied = self {
                return true
            }
            return false
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationStatus = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .authorized
            locationManager.startUpdatingLocation()
        @unknown default:
            locationStatus = .unknown
        }
    }
    
    func searchNearbyLibraries() {
        guard let userLocation = userLocation else {
            locationStatus = .error("Konum bilgisi bulunamadı")
            return
        }
        
        isLoading = true
        locationStatus = .searching
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "kütüphane"
        request.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.locationStatus = .error("Arama hatası: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                self.locationStatus = .error("Sonuç bulunamadı")
                return
            }
            
            let mapItems = response.mapItems
            
            if mapItems.isEmpty {
                self.locationStatus = .error("Yakınınızda kütüphane bulunamadı")
                return
            }
            
            self.libraries = mapItems.compactMap { item -> Library? in
                guard let name = item.name,
                      let location = item.placemark.location else { return nil }
                
                let distance = location.distance(from: userLocation)
                
                // Only include libraries within the search radius
                guard distance <= self.searchRadius else { return nil }
                
                return Library(
                    name: name,
                    address: self.getAddressFromPlacemark(item.placemark),
                    phoneNumber: item.phoneNumber ?? "Telefon bilgisi yok",
                    coordinate: item.placemark.coordinate,
                    distance: distance
                )
            }.sorted { $0.distance < $1.distance }
            
            self.locationStatus = self.libraries.isEmpty ? .error("Yakınınızda kütüphane bulunamadı") : .found
            
            // Update map region to show all libraries
            if !self.libraries.isEmpty {
                self.updateRegion()
            }
        }
    }
    
    private func getAddressFromPlacemark(_ placemark: MKPlacemark) -> String {
        var address = ""
        
        if let thoroughfare = placemark.thoroughfare {
            address += thoroughfare
        }
        
        if let subThoroughfare = placemark.subThoroughfare {
            address += " \(subThoroughfare)"
        }
        
        if !address.isEmpty {
            address += ", "
        }
        
        if let locality = placemark.locality {
            address += locality
        }
        
        if let subLocality = placemark.subLocality, !address.contains(subLocality) {
            address += ", \(subLocality)"
        }
        
        if let administrativeArea = placemark.administrativeArea, !address.contains(administrativeArea) {
            address += ", \(administrativeArea)"
        }
        
        return address.isEmpty ? "Adres bilgisi yok" : address
    }
    
    func updateRegion() {
        guard !libraries.isEmpty else { return }
        
        if libraries.count == 1, let library = libraries.first {
            region = MKCoordinateRegion(
                center: library.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            return
        }
        
        var minLat = libraries[0].coordinate.latitude
        var maxLat = libraries[0].coordinate.latitude
        var minLon = libraries[0].coordinate.longitude
        var maxLon = libraries[0].coordinate.longitude
        
        for library in libraries {
            minLat = min(minLat, library.coordinate.latitude)
            maxLat = max(maxLat, library.coordinate.latitude)
            minLon = min(minLon, library.coordinate.longitude)
            maxLon = max(maxLon, library.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    func selectLibrary(_ library: Library) {
        selectedLibrary = library
    }
    
    func getDirections(to library: Library) {
        guard let mapItem = library.mapItem else { return }
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters)) m"
        } else {
            let kilometers = meters / 1000
            return String(format: "%.1f km", kilometers)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension NearbyLibrariesViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Only update if location has changed significantly
        if userLocation == nil || userLocation!.distance(from: location) > 50 {
            userLocation = location
            
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            // Search for libraries when location is updated
            searchNearbyLibraries()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationStatus = .error("Konum hatası: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
