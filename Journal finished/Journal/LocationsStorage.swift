

import Foundation
import CoreLocation

//with this singleton, you’ll save locations to the documents folder of the app.
class LocationsStorage {
  static let shared = LocationsStorage()
  
  //to access all logged locations, which, for now, is set to an empty array in the initializer
  private(set) var locations: [Location]
  private let fileManager: FileManager
  private let documentsURL: URL
  
  init() {
    let fileManager = FileManager.default
    documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)    
    self.fileManager = fileManager
    
    
    
    let jsonDecoder = JSONDecoder()
    
    //1.Get URLs for all files in the Documents folder.
    let locationFilesURLs = try! fileManager.contentsOfDirectory(at: documentsURL,
    includingPropertiesForKeys: nil)
    locations = locationFilesURLs.compactMap { url -> Location? in
      
      //Skip the .DS_Store file.
      guard !url.absoluteString.contains(".DS_Store") else {
        return nil
      }
      
      //Read the data from the file
      guard let data = try? Data(contentsOf: url) else {
        return nil
      }
      
      //Decode the raw data into Location objects — thanks Codable
      return try? jsonDecoder.decode(Location.self, from: data)
      //Sort locations by date.
    }.sorted(by: { $0.date < $1.date })
  }
  
  func saveLocationOnDisk(_ location: Location) {
    
    //Create the encoder.
    let encoder = JSONEncoder()
    let timestamp = location.date.timeIntervalSince1970

    //Get the URL to file; for the file name, you use a date timestamp.
    let fileURL = documentsURL.appendingPathComponent("\(timestamp)")
    
    //Convert the location object to raw data.
    let data = try! encoder.encode(location)
    
    //Write data to the file
    try! data.write(to: fileURL)
    
    //Add the saved location to the local array.
    locations.append(location)
    
    //
    NotificationCenter.default.post(name: .newLocationSaved, object: self, userInfo: ["location": location])
  }
  
  func saveCLLocationToDisk(_ clLocation: CLLocation) {
    let currentDate = Date()
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let location = Location(clLocation.coordinate, date: currentDate, descriptionString: "\(place)")
        self.saveLocationOnDisk(location)
      }
    }
  }
}

//this is not UNNotification, but a Notification. to post a notification for the app to know that a new location was recorded.
extension Notification.Name {
  static let newLocationSaved = Notification.Name("newLocationSaved")
}

