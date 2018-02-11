//
//  LocationListController
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class LocationListController: UITableViewController {
    var categories = ["Chipotle", "Noodles & Company", "Panda", "Restaurant 4"]
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row]
        
        return cell
    }
    
    
}

