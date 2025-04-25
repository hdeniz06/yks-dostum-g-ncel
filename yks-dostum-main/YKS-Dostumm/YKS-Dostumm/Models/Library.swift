import Foundation
import CoreLocation
import MapKit

struct Library: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phoneNumber: String
    let coordinate: CLLocationCoordinate2D
    let distance: Double // in meters
    
    // For MapKit annotations
    var mapItem: MKMapItem? {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = name
        return item
    }
}
