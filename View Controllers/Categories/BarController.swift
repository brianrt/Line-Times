//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class BarController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userNames = ["Username 1", "Username 2", "Username 3", "Username 4"]
    var waitTimes = [5, 7, 4, 5]
    var reportedTimes = [5, 7, 10, 15]
    var bar = ""
    @IBOutlet var entries: UITableView!
    @IBOutlet var averageWait: UILabel!
    @IBOutlet weak var cover: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bar
        entries.delegate = self
        entries.dataSource = self
        
        averageWait.layer.borderColor = UIColor.lightGray.cgColor
        averageWait.layer.borderWidth = 0.5;
        
        cover.layer.borderColor = UIColor.lightGray.cgColor
        cover.layer.borderWidth = 0.5;
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! WaitTimesTableViewCell
        
        cell.userName.text = userNames[indexPath.row]
        cell.waitTime.text = "Wait time \(waitTimes[indexPath.row]) mins"
        cell.reportTime.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
        return cell
    }
    
    
}

