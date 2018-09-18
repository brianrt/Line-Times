//
//  BaseWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 6/7/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class BaseWaitTimeController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    var name = ""
    var categoryType = ""
    var locationIsEnabled = true
    
    var sv: UIView!
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    var radius: CLLocationDistance = 50.0 //meters
    var timeInterval = 1800.0 //seconds
    let locationManager = CLLocationManager()
    var venueLocation: CLLocation!
    var currentLocation: CLLocationCoordinate2D!
    var timeStampUrl = URL(string: "https://us-central1-time-crunch-e109e.cloudfunctions.net/getTimeStamp")
    var userSubmitEntryUrl = URL(string: "https://us-central1-time-crunch-e109e.cloudfunctions.net/app/userSubmitEntry")

    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var comments: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        self.title = name
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5;
        comments.delegate = self
        initiateLocation()
    }
    
    //Stop requesting location updates when exiting this view
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    //Set up location
    func initiateLocation() {
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            self.displayAlert(message: "You will not be able to add an entry if your location isn't enabled.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Dismiss Keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Convert address to coordinate
    func getCoordinate( addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        if(locationIsEnabled){
            while(currentLocation == nil){
                print(currentLocation)
            }
            print("got location!")
            print(currentLocation)
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true, completion: { (tokenID, error) in
                if let error = error {
                    self.displayAlert(message: error.localizedDescription)
                    return
                }
                // Send token to backend via HTTPS
                var request = URLRequest(url: self.userSubmitEntryUrl!)
                request.allHTTPHeaderFields = ["Authorization" : "Bearer " + tokenID!]
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpMethod = "POST"
                
                // Build up parameters
                let parameters = self.buildParameters()
                let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
                request.httpBody = jsonData
                
                //Send the request
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                        let title = (json!.value(forKey: "title") as! String) //message response title
                        let message = (json!.value(forKey: "message") as! String) //message response message
                        self.displayAlert(title: title, message: message)
                    } catch {
                        print("Error deserializing JSON: \(error)")
                    }
                }
                
                task.resume()
                
            })
            
//            sv = UIViewController.displaySpinner(onView: self.view)
//            self.ref.child("Categories").child(categoryType).child(name).child("Address").observeSingleEvent(of: .value) { (snapshot) in
//                //Get the address and convert to coordinate
//                let address = snapshot.value as! String
//                self.getCoordinate(addressString: address, completionHandler: { (coordinate, error) in
//                    if error == nil {
//                        //Verify user is within range of restaurant
//                        print(coordinate)
//                        self.venueLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                        self.locationManager.requestLocation()
//                    } else {
//                        self.displayAlert(message: "This location has an issue right now.")
//                        UIViewController.removeSpinner(spinner: self.sv)
//                    }
//                })
//            }
        } else {
            displayAlert(message: "Failed to find your location, please make sure location is enabled for this app.")
        }
    }
    
    // Build parameters to send in request to server
    func buildParameters() -> [String: Any] {
        let username = self.defaults.object(forKey: "username") as! String
        let uid = self.defaults.object(forKey: "userId") as! String
        let comment = self.comments.text!
        let locationEnabled = defaults.object(forKey: "LocationEnabled")
        let locationCheckDisabled = (locationEnabled != nil) && ((locationEnabled as! Bool) == false)
        let parameters = ["Username": username,
                          "Uid": uid,
                          "Latitude": currentLocation.latitude,
                          "Longitude": currentLocation.longitude,
                          "CategoryType": categoryType,
                          "VenueName": name,
                          "Comment": comment,
                          "DisableLocation": locationCheckDisabled
                        ] as [String : Any]
        return self.addItemsToSubmit(items: parameters)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.currentLocation = locValue
//        let userLocation = locations.first
//        if let distance = userLocation?.distance(from: venueLocation) {
//            if (distance <= radius) {
//                submitToDatabase()
//            } else if defaults.object(forKey: "LocationEnabled") != nil && (defaults.object(forKey: "LocationEnabled") as! Bool) == false {
//                //Check if we bypass location restriction in developer options
//                submitToDatabase()
//            } else {
//                displayAlert(message: "You must be at the venue location to submit an entry.")
//                UIViewController.removeSpinner(spinner: self.sv)
//            }
//        } else {
//            displayAlert(message: "Unable to get your location. Please make sure location is enabled.")
//            UIViewController.removeSpinner(spinner: self.sv)
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationIsEnabled = false
        self.displayAlert(message: "Heads up! You will not be able to submit an entry unless you allow location for this app.")
        if(self.sv != nil){
            UIViewController.removeSpinner(spinner: self.sv)
        }
    }
    
    func submitToDatabase() {
        let username = self.defaults.object(forKey: "username") as! String
        let uid = self.defaults.object(forKey: "userId") as! String
        let comment = self.comments.text!
        
        //Request a timestamp from the cloud
        let task = URLSession.shared.dataTask(with: timeStampUrl!) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as? NSDictionary
                let currentTimestamp = (json!.value(forKey: "timestamp") as! Double) //current timestamp
                var timeDiff = 0.0
                
                //Retreive User information to check for 30 minute validation
                self.ref.child("Users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                    var canSubmit = false
                    var entryCount = snapshot.childSnapshot(forPath: "entryCount").value as! Int
                    if snapshot.childSnapshot(forPath: "Entries/\(self.name)").hasChildren() {
                        //We have a past entry for this venue
                        let pastEntry = snapshot.childSnapshot(forPath: "Entries/\(self.name)").value as! [String: Double]
                        var postID = ""
                        var lastPostedTime = 0.0
                        for (key, value) in pastEntry {
                            postID = key
                            lastPostedTime = value
                        }
                        print(postID)
                        timeDiff = currentTimestamp - lastPostedTime
                        
                        //If they've posted more than 30 minutes ago, good to go
                        if timeDiff >= self.timeInterval {
                            canSubmit = true
                        }
                    } else {
                        //We have no past entry for this venue, good to go
                        canSubmit = true
                    }
                    
                    if canSubmit {
                        //Create a dictionary of items to upload
                        var items = ["Username": username, "Time Stamp": currentTimestamp, "Comment": comment] as [String : Any]
                        items = self.addItemsToSubmit(items: items)
                        
                        //Upload to firebase
                        self.ref.child("Categories").child(self.categoryType).child(self.name).child("Entries").childByAutoId().setValue(items) { (error, reference) in
                            //Add entry to their account for rewards as well as the venue, push ID and timestamp
                            let pushID = reference.key
                            let items = [pushID: currentTimestamp]
                            self.ref.child("Users").child(uid).child("Entries").child(self.name).setValue(items) {(error, reference) in
                                entryCount += 1
                                self.ref.child("Users").child(uid).child("entryCount").setValue(entryCount, withCompletionBlock: { (error, reference) in
                                    UIViewController.removeSpinner(spinner: self.sv)
                                    self.defaults.set(entryCount, forKey: "entryCount")
                                    self.navigationController?.popViewController(animated: true)
                                })
                            }
                        }
                    } else {
                        UIViewController.removeSpinner(spinner: self.sv)
                        self.displayAlert(message: "Entries can only be made every 30 minutes for a single location. You have \(Int((self.timeInterval - timeDiff)/60.0)) minutes remaining here.")
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                UIViewController.removeSpinner(spinner: self.sv)
            }
    
        }
        task.resume()
    }
    
    
    func addItemsToSubmit(items: [String: Any]) -> [String: Any] {
        return items
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
