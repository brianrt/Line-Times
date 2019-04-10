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
    @IBOutlet weak var yourCode: UILabel!
    
    var defaults: UserDefaults!
    var username: String!
    var ref = Database.database().reference()
    var referralCode: String!
    
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
//        defaults.set(false, forKey: "LocationEnabled")
        username = defaults.object(forKey: "username") as! String
        
        //Add observer for entryCount
        let userID = defaults.object(forKey: "userId") as? String
        self.ref.child("Users").child(userID!).child("entryCount").observe(.value) { (snapshot) in
            let entryCount = snapshot.value as? Int
            self.numEntriesLabel.text = String(entryCount!)
            self.defaults.set(entryCount, forKey: "entryCount")
        }
        
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
        
        //Grab the referal code from
        let referralCodePossible = self.defaults.object(forKey: "referralCode")
        if referralCodePossible == nil {
            let userId = self.defaults.object(forKey: "userId") as? String
            self.ref.child("Users").child(userId!).child("referralCode").observeSingleEvent(of: .value, with: { (snapshot) in
                self.referralCode = snapshot.value as! String
                self.defaults.set(self.referralCode, forKey: "referralCode")
                self.yourCode.text = self.referralCode
            })
        } else {
            referralCode = referralCodePossible as! String
            yourCode.text = referralCode
        }
        
        //Add shadows to nav bar
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.isTranslucent = false
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
            
            // Fetch the application link message from FireBase
            self.ref.child("ReferralMessage").observeSingleEvent(of: .value, with: { (snapshot) in
                let message = snapshot.value as! String
                // Configure the fields of the interface.
                composeVC.body = message + " Use my code: " + self.referralCode
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            })
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
