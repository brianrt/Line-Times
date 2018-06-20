//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class GymController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userNames = ["Username 1", "Username 2", "Username 3", "Username 4"]
    var howBusy = [5, 7, 4, 5]
    var reportedTimes = [5, 7, 10, 15]
    var gym = ""
    @IBOutlet var entries: UITableView!
    @IBOutlet var howFull: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = gym
        entries.delegate = self
        entries.dataSource = self
        
        howFull.layer.borderColor = UIColor.lightGray.cgColor
        howFull.layer.borderWidth = 0.5;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! EntryTwoRowTableViewCell
        
        cell.mainLabel.text = userNames[indexPath.row]
        cell.firstInfoLabel.text = "How Busy \(howBusy[indexPath.row])/10"
        cell.secondInfoLabel.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
        return cell
    }
}

