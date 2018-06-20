//
//  BaseCategoryController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 6/7/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BaseCategoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userNames: NSMutableArray = []
    var entriesList: NSMutableArray = []
    var reportedTimes: NSMutableArray = []
    var name = ""
    var ref = Database.database().reference()
    var averageValue = 0
    var categoryType = ""
    var waitIdentifier = ""
    
    @IBOutlet var entries: UITableView!
    @IBOutlet var averageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        entries.delegate = self
        entries.dataSource = self
        
        averageLabel.layer.borderColor = UIColor.lightGray.cgColor
        averageLabel.layer.borderWidth = 0.5;
    }
    
    func initLists() {
        userNames = []
        entriesList = []
        reportedTimes = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //The standard fetchEntries function for Library, Dining Hall, Gym
    func fetchEntries(){
        ref.child("Categories").child(categoryType).child(name).child("Entries").queryOrdered(byChild: "Time Stamp").observe(.value) { (snapshot) in
            self.initLists()
            for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                let entry = child.value as? NSDictionary
                self.userNames.add(entry!["Username"]!)
                self.entriesList.add(entry!["Busy Rating"]!)
                
                //Convert timestamp to time since in minutes
                let timeStamp = entry!["Time Stamp"] as! Double
                let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
                let elapsed = Date().timeIntervalSince(date)
                self.reportedTimes.add(Int(elapsed/60))
            }
            self.entries.reloadData()
            self.assignAverageLabel()
        }
    }
    
    //The standard assignAverageLabel function for Library, Dining Hall, Gym
    func assignAverageLabel(){
        ref.child("Categories").child(categoryType).child(name).child("Average Busy Rating").observe(.value) { (snapshot) in
            let averageBusyRating = snapshot.value as! String
            if(averageBusyRating == "N/A"){
                self.averageLabel.text = "   How Full: \(averageBusyRating)"
            } else {
                self.averageLabel.text = "   How Full: \(averageBusyRating)/10"
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    //The standard cellForRowAt function for Library, Dining Hall, Gym
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTwoCell", for: indexPath) as! EntryTwoRowTableViewCell
        
        cell.mainLabel.text = userNames[indexPath.row] as? String
        cell.firstInfoLabel.text = "How Busy \(entriesList[indexPath.row])/10"
        cell.secondInfoLabel.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
        return cell
    }
    
    @IBAction func recordWaitPressed(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: waitIdentifier) as? BaseWaitTimeController {
            if let navigator = navigationController {
                viewController.name = name
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}
