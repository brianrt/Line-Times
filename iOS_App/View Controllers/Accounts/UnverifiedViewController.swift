//
//  UnverifiedViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 10/9/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class UnverifiedViewController: UIViewController {
    var timer = Timer()
    var defaults: UserDefaults!
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults = UserDefaults.standard
        
        //Hide back button
        let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        
        //Add logout button to top right
        let signOutButton = UIBarButtonItem(title: "Signout", style: .plain, target: self, action: #selector(signOut))
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = signOutButton
        
        // Scheduling timer to Call the function "listenForEmailVerified" with the interval of 1 second
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.reloadUser), userInfo: nil, repeats: true)
    }
    
    @objc func signOut() {
        do {
            self.defaults.set(nil, forKey: "userId")
            self.defaults.set(nil, forKey: "username")
            self.defaults.set(nil, forKey: "entryCount")
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch (let error) {
            displayAlert(title: "Sign out failed", message: error.localizedDescription)
        }
    }
    
    @objc func reloadUser() {
        Auth.auth().currentUser?.reload(completion: { (error) in
            self.listenForEmailVerified()
        })
    }
    
    func listenForEmailVerified() {
        let isEmailVerified = Auth.auth().currentUser!.isEmailVerified
        if (isEmailVerified) {
            timer.invalidate()
            self.displayVerifiedAlert(title: "Thank you for verifying", message: "You may now proceed to use the app.")
        }
    }
    
    @IBAction func sendVerificationEmail(_ sender: Any) {
        //Send a validation email here
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error == nil {
                self.displayAlert(title: "Email Verification Sent", message: "Please check your email and click on the link to verify your account.")
            } else {
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Here we know the user is logged in and verified, can store user data in database
    func displayVerifiedAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            
            //Here we will upload the username and 0 for count entries
            let user = Auth.auth().currentUser
            let username = self.defaults.object(forKey: "username") as! String
            let entryCount = 0
            
            self.defaults.set(entryCount, forKey: "entryCount")
            self.defaults.set(user?.uid, forKey: "userId")
            
            self.ref.child("Users").child((user?.uid)!).setValue(["username": username, "entryCount": entryCount], withCompletionBlock: { (error, reference) in
                self.navigationController?.popViewController(animated: true)
            })
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
