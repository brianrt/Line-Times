//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RestaurantWaitTimeController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var waitTimes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    var restaurant = ""
    var waitTime = 0
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var submit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant
        defaults = UserDefaults.standard
        
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.layer.borderWidth = 0.5
        timePicker.layer.borderColor = UIColor.lightGray.cgColor
        
        costField.delegate = self
        costField.addDoneButtonToKeyboard(myAction:  #selector(self.costField.resignFirstResponder))
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5
        comments.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return waitTimes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(waitTimes[row]) mins"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        waitTime = waitTimes[row]
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y -= self.view.frame.height/3.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y += self.view.frame.height/3.0
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        //Verify user hasn't submitted one in 30 minutes
        //Verify user is within range of restaurant
        let timestamp = NSDate().timeIntervalSince1970
        let username = defaults.object(forKey: "username") as! String
        var cost = "0.00"
        if(costField.text != ""){
            cost = costField.text!
        }
        let comment = comments.text!
        
        //Upload to firebase
        self.ref.child("Categories").child("Restaurants").child(restaurant).child("Entries").childByAutoId().setValue(["Username": username, "Time Stamp": timestamp, "Wait Time": NSString(format: "%d", waitTime), "Cost": cost, "Comment": comment]) { (error, reference) in
            print("entered")
            //Add entry to their account for rewards
        }
    }
    
    
}
