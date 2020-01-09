

import UIKit
import MapKit

class MapViewController: UIViewController {
  
  //MKMapView hooked up from the storyboard.
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.userTrackingMode = .follow
    
    //This code generates pins from locations that you've already created and adds them to the map.
    let annotations = LocationsStorage.shared.locations.map { annotationForLocation($0) }
    mapView.addAnnotations(annotations)
    //you need to listen for the notification in order to know when this new location is recorded.
    NotificationCenter.default.addObserver(self, selector: #selector(newLocationAdded(_:)), name: .newLocationSaved, object: nil)
  }
  
  @IBAction func addItemPressed(_ sender: Any) {
    guard let currentLocation = mapView.userLocation.location else {
      return
    }
    
    LocationsStorage.shared.saveCLLocationToDisk(currentLocation)
  }
  
  
  //To add pins to the map, you need to convert locations to MKAnnotation, which is a protocol that represents objects on a map.
  func annotationForLocation(_ location: Location) -> MKAnnotation {
    let annotation = MKPointAnnotation()
    annotation.title = location.dateString
    annotation.coordinate = location.coordinates
    return annotation
  }
  
  @objc func newLocationAdded(_ notification: Notification) {
    guard let location = notification.userInfo?["location"] as? Location else {
      return
    }
    
    let annotation = annotationForLocation(location)
    mapView.addAnnotation(annotation)
  }
}
