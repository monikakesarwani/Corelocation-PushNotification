
//import framework
import UIKit // is to listens to user location updates
import CoreLocation // to show banner notifications when the app logs a new location.
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  static let geoCoder = CLGeocoder()
  
  //Through these two properties, you’ll access the API of the two frameworks above.
  let center = UNUserNotificationCenter.current()
  let locationManager = CLLocationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let rayWenderlichColor = UIColor(red: 0/255, green: 104/255, blue: 55/255, alpha: 1)
    UITabBar.appearance().tintColor = rayWenderlichColor
    
    //to specify what kind of notifications you want to post. You also include an empty closure because you assume, for this tutorial, that users always give you permission. You can handle the denial in this closure.
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    }
    
    //Asking for User Locations both in the background and the foreground
    locationManager.requestAlwaysAuthorization()
    
    locationManager.startMonitoringVisits()
    locationManager.delegate = self
    
     //Uncomment following code to enable fake visits
    locationManager.distanceFilter = 35 // 0
    locationManager.allowsBackgroundLocationUpdates = true // 1
    locationManager.startUpdatingLocation()  // 2
    
    return true
  }
}

extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
    
    /* Get location description, to get an address from a set of coordinates, you use reverse geocoding location
     you ask geoCoder to get placemarks from the location. The placemarks contain a bunch of useful information about the coordinates, including their addresses.
 */
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "\(place)"
        self.newVisitReceived(visit, description: description)
      }
    }
  }
  
  //to notify a user when the new visit location is logged
  func newVisitReceived(_ visit: CLVisit, description: String) {
    let location = Location(visit: visit, descriptionString: description)
    
    //whenever the app receives a visit, it will grab the location description, create a Location object and save it to disk.
    LocationsStorage.shared.saveLocationOnDisk(location)
    
    //1. Create notification content.
    let content = UNMutableNotificationContent()
    content.title = "New Journal entry 📌"
    content.body = location.description
    content.sound = UNNotificationSound.default
    
    //2. Create a one second long trigger and notification request with that trigger.
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
    
    //3. Schedule the notification by adding the request to notification center.
    center.add(request, withCompletionHandler: nil)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    
    AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "Fake visit: \(place)"
        
        let fakeVisit = FakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
        self.newVisitReceived(fakeVisit, description: description)
      }
    }
  }
}

final class FakeVisit: CLVisit {
  private let myCoordinates: CLLocationCoordinate2D
  private let myArrivalDate: Date
  private let myDepartureDate: Date

  override var coordinate: CLLocationCoordinate2D {
    return myCoordinates
  }
  
  override var arrivalDate: Date {
    return myArrivalDate
  }
  
  override var departureDate: Date {
    return myDepartureDate
  }
  
  init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
    myCoordinates = coordinates
    myArrivalDate = arrivalDate
    myDepartureDate = departureDate
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
