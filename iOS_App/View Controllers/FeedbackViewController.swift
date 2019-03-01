//
//  FeedbackViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 7/13/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var feedback: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    var sv: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }
    
    
    
    func customSetup() {
        if self.revealViewController() != nil {
            revealButtonItem.target = self.revealViewController()
            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.title = "Feedback"
        feedback.layer.borderColor = UIColor.lightGray.cgColor
        feedback.layer.borderWidth = 0.5;
        feedback.delegate = self
        feedback.becomeFirstResponder()
        defaults = UserDefaults.standard
        
        submitButton.layer.cornerRadius = 15
        submitButton.layer.borderColor = UIColor.black.cgColor
        submitButton.layer.borderWidth = 1.0
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let feedBackResponse = feedback.text
        if(feedBackResponse == ""){
            displayErrorAlert(message: "Please fill out the feedback form.")
        } else {
            sv = UIViewController.displaySpinner(onView: self.view)
            let uid = defaults.object(forKey: "userId") as! String
            let entry = [uid: feedBackResponse]
            self.ref.child("Feedback").childByAutoId().setValue(entry) { (error, reference) in
                UIViewController.removeSpinner(spinner: self.sv)
                self.displayAlert(title: "Thank you for your feedback!", message: "Your submission has been sent.")
                let categoryViewController = self.storyboard?.instantiateViewController(withIdentifier: "Category")
                self.revealViewController().setFront(categoryViewController, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayErrorAlert(message: String) {
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
