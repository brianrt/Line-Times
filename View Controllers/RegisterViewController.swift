//
//  RegisterViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
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
        confirmField.delegate = self
        emailField.becomeFirstResponder()
        
        defaults = UserDefaults.standard
    }
    
    @IBAction func didPressContinue(_ sender: Any) {
        createUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailField { // Switch focus to other text field
            passwordField.becomeFirstResponder()
        } else if textField == passwordField { // Switch focus to other text field
            confirmField.becomeFirstResponder()
        } else {
            createUser()
        }
        return true
    }
    
    func createUser(){
        let email = emailField.text
        let password = passwordField.text
        let confirm = confirmField.text
        
        if password?.count == 0 {
            displayAlert(message: "Please enter a valid password")
        }
        else if password != confirm {
            displayAlert(message: "Please ensure passwords match")
        } else {
            // We are good to go
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                if error == nil { //Successfuly created user
                    self.defaults.set(nil, forKey: "user_id")
                    Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user, error) in
                        if error == nil { //Successfuly signed in
                            //Here we will upload the username and 0 for count entries 
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.displayAlert(message: (error?.localizedDescription)!)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    
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

