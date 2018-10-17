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
    let locationManager = CLLocationManager()
    var venueLocation: CLLocation!
    var currentLocation: CLLocationCoordinate2D!
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
    
    @IBAction func submitPressed(_ sender: Any) {
        if(locationIsEnabled){
            sv = UIViewController.displaySpinner(onView: self.view) //Start spinner
            let start = CFAbsoluteTimeGetCurrent()
            var elapsed = CFAbsoluteTimeGetCurrent() - start
            
            //Wait at most 10 seconds for location, otherwise time out
            while(currentLocation == nil && elapsed < 5.0) {
                elapsed = CFAbsoluteTimeGetCurrent() - start
                print(elapsed)
            }
            if(elapsed >= 5.0){
                displayAlert(message: "Timed out finding your location, please try again later.")
            } else {
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
                            let error = (json!.value(forKey: "error") as! Bool) //If there was an error or not
                            if (error) {
                                let title = (json!.value(forKey: "title") as! String) //message response title
                                let message = (json!.value(forKey: "message") as! String) //message response message
                                UIViewController.removeSpinner(spinner: self.sv) //remove spinner
                                self.displayAlert(title: title, message: message)
                            } else {
                                let entryCount = (json!.value(forKey: "entryCount") as! Int)
                                UIViewController.removeSpinner(spinner: self.sv)
                                self.defaults.set(entryCount, forKey: "entryCount")
                                DispatchQueue.main.async { [unowned self] in
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                    }
                    task.resume()
                })
            }
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
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationIsEnabled = false
        self.displayAlert(message: "Heads up! You will not be able to submit an entry unless you allow location for this app.")
        if(self.sv != nil){
            UIViewController.removeSpinner(spinner: self.sv)
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
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
