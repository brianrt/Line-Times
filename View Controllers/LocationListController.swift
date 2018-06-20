//
//  LocationListController
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class LocationListController: UITableViewController {
    var categoryIndex = 0
    var categories = ["Restaurants", "Bars", "Libraries", "Dining Halls", "Gyms"]
    var locations: NSMutableArray = []
    var entries: NSMutableArray = []
    var covers: NSMutableArray = []
    var ref = Database.database().reference()
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category = categories[categoryIndex]
        self.title = category
        
        //Setup nib for custom cells
        var nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        if(category == "Bars"){
            nib = UINib(nibName: "EntryTwoRowTableViewCell", bundle: nil)
        }
        tableView.register(nib, forCellReuseIdentifier: "CategoriesCell")
        fetchLocations()
    }
    
    func initLists(){
        locations = []
        entries = []
        covers = []
    }
    
    //Populate the locations array from the database
    func fetchLocations(){
        ref.child("Categories").child(category).observe(.value) { (snapshot) in
            self.initLists()
            // Get user value
            let venue = snapshot.value as? NSDictionary
            for (name, value) in venue! {
                let data = value as! NSDictionary
                self.locations.add(name)
                if(self.category == "Bars"){
                    let cover = data["Most Frequent Cover"] as! String
                    if(cover == "N/A"){
                        self.covers.add(cover)
                    } else {
                        self.covers.add("$" + cover)
                    }
                    let waitTime = data["Average Wait Time"] as! String
                    if(waitTime == "N/A"){
                        self.entries.add(waitTime)
                    } else {
                        self.entries.add(waitTime+" mins")
                    }
                } else if(self.category == "Restaurants"){
                    let waitTime = data["Average Wait Time"] as! String
                    if(waitTime == "N/A"){
                        self.entries.add(waitTime)
                    } else {
                        self.entries.add(waitTime+" mins")
                    }
                } else {
                    let busyRating = data["Average Busy Rating"] as! String
                    if(busyRating == "N/A"){
                        self.entries.add(busyRating)
                    } else {
                        self.entries.add(busyRating+"/10")
                    }
                }
            }
            self.tableView.reloadData()
        }
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
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 85
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch categoryIndex {
            case 0:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? RestaurantController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 1:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? BarController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 2:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? LibraryController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 3:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? DiningHallController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 4:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: category) as? GymController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(category == "Bars"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! EntryTwoRowTableViewCell
            cell.mainLabel.text = locations[indexPath.row] as? String
            cell.firstInfoLabel.text = "Wait time: \(entries[indexPath.row])"
            cell.secondInfoLabel.text = "Cover: \(covers[indexPath.row])"
            return cell
        } else if(category == "Restaurants"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
            cell.mainLabel.text = locations[indexPath.row] as? String
            cell.infoLabel.text = "Wait time: \(entries[indexPath.row])"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
            cell.mainLabel.text = locations[indexPath.row] as? String
            cell.infoLabel.text = "Busy: \(entries[indexPath.row])"
            return cell
        }
    }
}

