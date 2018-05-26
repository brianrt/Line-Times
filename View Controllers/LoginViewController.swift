//
//  LoginViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    var defaults: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }
    
    func customSetup() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Welcome to Time Crunch!"
        
        //Set text field delegates
        emailField.delegate = self
        passwordField.delegate = self
        emailField.becomeFirstResponder()
        
        defaults = UserDefaults.standard
    }
    
    @IBAction func didPressContinue(_ sender: Any) {
        logIn()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailField { // Switch focus to other text field
            passwordField.becomeFirstResponder()
        } else {
            logIn()
        }
        return true
    }
    
    func logIn(){
        let email = emailField.text
        let password = passwordField.text
        
        if password?.count == 0 {
            displayAlert(message: "Please enter a valid password")
        } else {
            // We are good to go
            Auth.auth().signIn(withEmail: email!, password: password!) { user, error in
                if error == nil { //Successfuly logged in
                    self.defaults.set(nil, forKey: "user_id")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayAlert(message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

