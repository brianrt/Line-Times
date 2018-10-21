//
//  RegisterViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var defaults: UserDefaults!
    var ref = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }
    
    func customSetup() {
        //Hide nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Set text field delegates
        emailField.delegate = self
        passwordField.delegate = self
        confirmField.delegate = self
        usernameField.delegate = self
        
        //Set underlines to text fields
        emailField.underlined()
        passwordField.underlined()
        confirmField.underlined()
        usernameField.underlined()
        
        //Set button UI
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 15
        registerButton.layer.borderWidth = 0.25
        registerButton.layer.borderColor = UIColor.lightGray.cgColor
        
        defaults = UserDefaults.standard
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func didPressContinue(_ sender: Any) {
        createUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailField { // Switch focus to other text field
            usernameField.becomeFirstResponder()
        } else if textField == usernameField { // Switch focus to other text field
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
        let username = usernameField.text
        
        if password?.count == 0 {
            displayAlert(message: "Please enter a valid password")
        }
        else if password != confirm {
            displayAlert(message: "Please ensure passwords match")
        } else {
            self.appDelegate.isRegistering = true
            Auth.auth().createUser(withEmail: email!, password: password!) { user, error in
                if error == nil { //Successfuly created user
                    //Send a validation email here
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if error == nil {
                            self.defaults.set(username, forKey: "username")
                            self.displayVerificationAlert(title: "Email Verification Sent", message: "Thank you for registering! Please check your email and click on the link to verify your account. You will not be able to use the app until you have verified your email!")
                        } else {
                            self.displayAlert(message: (error?.localizedDescription)!)
                            self.appDelegate.isRegistering = false
                        }
                    }
                } else {
                    self.displayAlert(message: (error?.localizedDescription)!)
                    self.appDelegate.isRegistering = false
                }
            }
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayVerificationAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.performSegue(withIdentifier: "toUnverified", sender: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y -= self.view.frame.height/5.0
        }
    }
    
    func textFieldDidEndEditing(_ textView: UITextField) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y += self.view.frame.height/5.0
        }
    }
}

