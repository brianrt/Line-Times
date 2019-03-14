//
//  AccountViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseDatabase

class AccountViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var numEntriesLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var referAFriend: UIButton!
    
    var defaults: UserDefaults!
    var username: String!
    var ref = Database.database().reference()
    
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
        defaults = UserDefaults.standard
        username = defaults.object(forKey: "username") as! String
        numEntriesLabel.text = String((defaults.object(forKey: "entryCount") as? Int)!)
        setCanEdit()
        edit.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        save.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        userNameText.delegate = self
        let LocationEnabled = defaults.object(forKey: "LocationEnabled")
        if(LocationEnabled != nil && (LocationEnabled as! Bool) == false){
            segmentedControl.selectedSegmentIndex = 1;
        } else {
            segmentedControl.selectedSegmentIndex = 0;
        }
        self.title = "Account"
        
        //Button UI
        
        save.backgroundColor = .clear
        save.layer.cornerRadius = 5
        save.layer.borderWidth = 0.25
        save.layer.borderColor = UIColor.lightGray.cgColor
        
        edit.backgroundColor = .clear
        edit.layer.cornerRadius = 5
        edit.layer.borderWidth = 0.25
        edit.layer.borderColor = UIColor.lightGray.cgColor
        
        referAFriend.backgroundColor = .clear
        referAFriend.layer.cornerRadius = 10
        referAFriend.layer.borderWidth = 0.25
        referAFriend.layer.borderColor = UIColor.lightGray.cgColor
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCanEdit() {
        userNameLabel.isHidden = false
        edit.isHidden = false
        userNameText.isHidden = true
        save.isHidden = true
        userNameLabel.text = username
    }
    
    func setCanSave() {
        userNameLabel.isHidden = true
        edit.isHidden = true
        userNameText.isHidden = false
        save.isHidden = false
        if username != nil && username.count > 0{
            userNameText.text = username
        }
    }
    
    @objc func editPressed(sender: UIButton!) {
        userNameText.becomeFirstResponder()
        setCanSave()
    }
    
    @objc func savePressed(sender: UIButton!) {
        
        // Update value of username in database
        username = userNameText.text
        let userID = defaults.object(forKey: "userId") as? String
        self.ref.child("Users").child(userID!).updateChildValues(["username": username!]) { (error, reference) in
            if error == nil {
                self.defaults.set(self.username, forKey: "username")
                self.userNameText.endEditing(true)
                self.setCanEdit()
            } else {
                self.displayAlert(message: (error?.localizedDescription)!)
                self.userNameText.endEditing(true)
                self.setCanEdit()
            }
        }
    }
    
    @IBAction func referAFriendPressed(_ sender: Any) {
        
        if !MFMessageComposeViewController.canSendText() {
            displayAlert(message: "SMS services are not available")
        } else {
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.body = "Hello from California!"
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        savePressed(sender: nil)
        return true
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Function for enabling location options
    @IBAction func didSwitchEnableLocation(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                defaults.set(true, forKey: "LocationEnabled")
                break
            case 1:
                defaults.set(false, forKey: "LocationEnabled")
                break
            default:
                break
        }
    }
    
}
