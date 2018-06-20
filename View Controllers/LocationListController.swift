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
    var locations: NSMutableArray!
    var wait_times: NSMutableArray!
    var ref = Database.database().reference()
    var category: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        category = categories[categoryIndex]
        self.title = category
        locations = []
        wait_times = []
        
        //Setup nib for custom cells
        let nib = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CategoriesCell")

        fetchLocations()
    }
    
    //Populate the locations array from the database
    func fetchLocations(){
        ref.child("Categories").child(category).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let restaurants = snapshot.value as? NSDictionary
            for (name, _) in restaurants! {
                self.locations.add(name)
                self.wait_times.add(0)
            }
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
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
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: categories[categoryIndex]) as? RestaurantController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 1:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: categories[categoryIndex]) as? BarController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 2:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: categories[categoryIndex]) as? LibraryController {
                    if let navigator = navigationController {
                        viewController.name = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 3:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: categories[categoryIndex]) as? DiningHallController {
                    if let navigator = navigationController {
                        viewController.diningHall = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            case 4:
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: categories[categoryIndex]) as? GymController {
                    if let navigator = navigationController {
                        viewController.gym = locations[indexPath.row] as! String
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
        
        cell.mainLabel.text = locations[indexPath.row] as? String
        cell.infoLabel.text = "Wait time: \(wait_times[indexPath.row]) mins"
        
        return cell
    }
}

