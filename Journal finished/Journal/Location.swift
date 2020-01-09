

import Foundation
import CoreLocation

//need to save objects of this class on disk. In order to do that, this class conforms to Codable
class Location: Codable {
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
  }()
  
  
  //There is a computed property to convert the Location object to CLLocationCoordinate2D
  var coordinates: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  let latitude: Double
  let longitude: Double
  let date: Date
  let dateString: String
  let description: String
  
  init(_ location: CLLocationCoordinate2D, date: Date, descriptionString: String) {
    latitude =  location.latitude
    longitude =  location.longitude
    self.date = date
    dateString = Location.dateFormatter.string(from: date)
    description = descriptionString
  }
  
  convenience init(visit: CLVisit, descriptionString: String) {
    self.init(visit.coordinate, date: visit.arrivalDate, descriptionString: descriptionString)
  }
}
