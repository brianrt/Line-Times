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

class BaseWaitTimeController: UIViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    
    var name = ""
    var categoryType = ""
    
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    var radius: CLLocationDistance = 50.0 //meters
    let locationManager = CLLocationManager()
    var venueLocation: CLLocation!

    
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
    
    //Set up location
    func initiateLocation() {
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first
        if let distance = userLocation?.distance(from: venueLocation) {
            if (distance <= radius) {
                submitToDatabase()
            } else {
                displayAlert(message: "You must be at the venue location to submit an entry.")
            }
        } else {
            displayAlert(message: "Unable to get your location. Please make sure location is enabled.")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayAlert(message: "Failed to find your location: \(error.localizedDescription)")
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        self.ref.child("Categories").child(categoryType).child(name).child("Address").observeSingleEvent(of: .value) { (snapshot) in
            //Get the address and convert to coordinate
            let address = snapshot.value as! String
            self.getCoordinate(addressString: address, completionHandler: { (coordinate, error) in
                if error == nil {
                    //Verify user is within range of restaurant
                    print(coordinate)
                    self.venueLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    self.locationManager.requestLocation()
                } else {
                    print("address didn't work")
                }
            })
        }
    }
    
    func submitToDatabase() {
        //Verify user hasn't submitted one in 30 minutes
        let timestamp = NSDate().timeIntervalSince1970
        let username = self.defaults.object(forKey: "username") as! String
        let comment = self.comments.text!

        //Create a dictionary of items to upload
        var items = ["Username": username, "Time Stamp": timestamp, "Comment": comment] as [String : Any]
        items = self.addItemsToSubmit(items: items)

        //Upload to firebase
        self.ref.child("Categories").child(self.categoryType).child(self.name).child("Entries").childByAutoId().setValue(items) { (error, reference) in
            print("entered")
            //Add entry to their account for rewards
        }
    }
    
    func addItemsToSubmit(items: [String: Any]) -> [String: Any] {
        return items
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
