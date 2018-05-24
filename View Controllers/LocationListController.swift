//
//  LocationListController
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class LocationListController: UITableViewController {
    var categoryIndex = 0
    var categories = ["Restaurants", "Bars", "Libraries", "Gyms"]
    var locations = ["Chipotle", "Noodles & Co.", "Panda", "Restaurant 4"]
    var wait_times = [10,12,3,2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Restaurants"
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
        return 4
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
                        viewController.restaurant = locations[indexPath.row]
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
        
        cell.category.text = locations[indexPath.row]
        cell.countInfo.text = "Wait time: \(wait_times[indexPath.row]) mins"
        
        return cell
    }
}

