//
//  CategoryController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class CategoryController: UITableViewController {
    var categories = ["Restaurants", "Bars", "Libraries", "Gyms"]
    var counts = [10,12,3,2]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Champaign"
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as! CategoryTableViewCell
        
        cell.category.text = categories[indexPath.row]
        cell.countInfo.text = "\(counts[indexPath.row]) " + categories[indexPath.row]
        
        return cell
    }
    
    
}
