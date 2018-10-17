//
//  LoginViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    var defaults: UserDefaults!
    var ref = Database.database().reference()
    
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
    
    @IBAction func sendResetPasswordEmail(_ sender: Any) {
        let email = emailField.text
        if email?.count == 0 {
            self.displayAlert(title: "Email Empty", message: "Please provide your email in the email field")
        } else {
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if error == nil {
                    self.displayAlert(title: "Success", message: "Please check your email for a password reset link")
                } else {
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }
            }
        }
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
            displayAlert(title: "Error", message: "Please enter a valid password")
        } else {
            Auth.auth().signIn(withEmail: email!, password: password!) { user, error in
                if error != nil {
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

