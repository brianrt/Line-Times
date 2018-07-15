//
//  ViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/1/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class MenuController: UITableViewController {
    var menuItems = ["Champaign", "About", "Account", "Feedback", "Logout"] //TEMP
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        if(menuItems[indexPath.row] == "Champaign"){ //TEMP
            self.revealViewController().setFront(appDelegate.champaignViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "About"){
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "About")
            self.revealViewController().setFront(aboutViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "Account"){
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "Account")
            self.revealViewController().setFront(aboutViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "Feedback"){
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "Feedback")
            self.revealViewController().setFront(aboutViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "Logout"){
            do {
                try Auth.auth().signOut()
                self.defaults.set(nil, forKey: "userId")
                self.defaults.set(nil, forKey: "username")
                self.defaults.set(nil, forKey: "entryCount")
                self.revealViewController().setFront(appDelegate.champaignViewController, animated: false) //TEMP
            } catch (let error) {
                displayAlert(message: "Sign out failed: \(error)")
            }
        }
        self.revealViewController().revealToggle(animated: true)
        
    }

    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

