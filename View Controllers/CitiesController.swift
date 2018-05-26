//
//  CitiesController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CitiesController: UITableViewController {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfLoggedIn()
        customSetup()
    }
    
    var cities = ["Champaign"]
    var counts = [5,5,3,4]
    var defaults: UserDefaults!
    var ref = Database.database().reference()
    
    func customSetup() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.citiesViewController = self.navigationController
        defaults = UserDefaults.standard
        if self.revealViewController() != nil {
            revealButtonItem.target = self.revealViewController()
            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func checkIfLoggedIn() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.defaults.set(user?.uid, forKey: "userId")
                self.ref.child("Users").child((user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user values
                    let value = snapshot.value as? NSDictionary
                    let username = value?["username"] as? String
                    let entryCount = value?["entryCount"] as? Int
                    self.defaults.set(username, forKey: "username")
                    self.defaults.set(entryCount, forKey: "entryCount")
                })
            } else {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as? LoginViewController
                self.navigationController?.pushViewController(viewController!, animated: true)
            }
        }
        
//        self.defaults.set(nil, forKey: "userId")
//        if (defaults.object(forKey: "userId") == nil){
//            //User has not registered before
//
//        }
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 85
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
        
        cell.category.text = cities[indexPath.row]
        cell.countInfo.text = "\(counts[indexPath.row]) Categories"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
}


