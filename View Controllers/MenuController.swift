//
//  ViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/1/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    var menuItems = ["Username", "Friends", "Settings", "Register Location", "About", "Contact",
                  "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = menuItems[indexPath.row]
        
        return cell
    }


}

