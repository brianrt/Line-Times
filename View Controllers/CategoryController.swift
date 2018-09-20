//
//  CategoryController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

 //TEMP
import FirebaseAuth
import FirebaseDatabase

class CategoryController: UITableViewController {
    var categories = ["Restaurants", "Bars", "Libraries", "Dining Halls", "Gyms"]
    var counts = [10,12,3,5,2]
    
     //TEMP
    var defaults: UserDefaults!
    var ref = Database.database().reference()
     @IBOutlet var revealButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Champaign"
        
        //Setup nib for custom cells
        let nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CategoriesCell")
        
        //Skip over cities, must do this
         //TEMP
        checkIfLoggedIn()
        customSetup()
    }
    
    //######################### Temporary skipping over Cities controller #########################' TEMP
    func customSetup() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.champaignViewController = self.navigationController
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
    }
    //######################### End Temporary skipping over Cities controller #########################
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
       return 85
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "locationList") as? LocationListController {
            if let navigator = navigationController {
                viewController.categoryIndex = indexPath.row
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
        
        cell.mainLabel.text = categories[indexPath.row]
        cell.infoLabel.text = "\(counts[indexPath.row]) " + categories[indexPath.row]
        
        return cell
    }
    
    
}
