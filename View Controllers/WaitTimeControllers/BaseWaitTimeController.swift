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

class BaseWaitTimeController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var name = ""
    var categoryType = ""
    
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    var radius = 50 //meters
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var comments: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        self.title = name
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5;
        comments.delegate = self
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
        self.ref.child("Categories").child(categoryType).child(name).child("Address").observeSingleEvent(of: .value) { (snapshot) in
            //Get the address and convert to coordinate
            let address = snapshot.value as! String
            self.getCoordinate(addressString: address, completionHandler: { (coordinate, error) in
                if error == nil {
                    //Verify user is within range of restaurant
                    print(coordinate)
                    
                    //Verify user hasn't submitted one in 30 minutes
                    let timestamp = NSDate().timeIntervalSince1970
                    let username = self.defaults.object(forKey: "username") as! String
                    let comment = self.comments.text!
                    
                    //Create a dictionary of items to upload
                    var items = ["Username": username, "Time Stamp": timestamp, "Comment": comment] as [String : Any]
                    items = self.augmentItemsToSubmit(items: items)
                    
                    //Upload to firebase
                    self.ref.child("Categories").child(self.categoryType).child(self.name).child("Entries").childByAutoId().setValue(items) { (error, reference) in
                        print("entered")
                        //Add entry to their account for rewards
                    }
                } else {
                    print("address didn't work")
                }
            })
        }
    }
    
    func augmentItemsToSubmit(items: [String: Any]) -> [String: Any] {
        return items
    }
}
