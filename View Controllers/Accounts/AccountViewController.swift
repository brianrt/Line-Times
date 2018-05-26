//
//  AccountViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var numEntriesLabel: UILabel!
    
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
        setCanEdit()
        edit.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        save.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        userNameText.delegate = self
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        savePressed(sender: nil)
        return true
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
