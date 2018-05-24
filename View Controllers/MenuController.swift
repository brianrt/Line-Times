//
//  ViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/1/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    var menuItems = ["Cities", "About", "Username", "Friends", "Settings", "Register Location", "Contact",
                  "Logout"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if defaults.object(forKey: "username") != nil {
            menuItems[2] = defaults.object(forKey: "username") as! String
        }
        self.tableView.reloadData()
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
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("You selected cell number: \(indexPath.row)!")
        if(menuItems[indexPath.row] == "Cities"){
            self.revealViewController().setFront(appDelegate.citiesViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "About"){
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "About")
//            self.revealViewController().pushFrontViewController(aboutViewController, animated: false)
            self.revealViewController().setFront(aboutViewController, animated: false)
        }
        else if(menuItems[indexPath.row] == "Username" || menuItems[indexPath.row] == defaults.object(forKey: "username") as! String){
            let aboutViewController = self.storyboard?.instantiateViewController(withIdentifier: "Username")
            self.revealViewController().setFront(aboutViewController, animated: false)
        }
        self.revealViewController().revealToggle(animated: true)
        
    }


}

