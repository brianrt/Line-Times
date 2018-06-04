//
//  LocationController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RestaurantController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var userNames: NSMutableArray!
    var waitTimes: NSMutableArray!
    var reportedTimes: NSMutableArray!
    var restaurant = ""
    var ref = Database.database().reference()
    
    @IBOutlet var entries: UITableView!
    @IBOutlet var averageWait: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant
        entries.delegate = self
        entries.dataSource = self
        
        averageWait.layer.borderColor = UIColor.lightGray.cgColor
        averageWait.layer.borderWidth = 0.5;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userNames = []
        waitTimes = []
        reportedTimes = []
        fetchEntries()
    }
    
    func fetchEntries(){
        var averageWaitTime = "   Average Wait: N/A"
        ref.child("Categories").child("Restaurants").child(restaurant).child("Entries").queryOrdered(byChild: "Time Stamp").observeSingleEvent(of: .value) { (snapshot) in
            if(snapshot.value != nil){
                var sumWait = 0
                var count = 0
                for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                    let entry = child.value as? NSDictionary
                    self.userNames.add(entry!["Username"]!)
                    let wait = entry!["Wait Time"]!
                    self.waitTimes.add(wait)
                    sumWait += Int(wait as! String)!
                    count += 1

                    //Convert timestamp to time since in minutes
                    let timeStamp = entry!["Time Stamp"] as! Double
                    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
                    let elapsed = Date().timeIntervalSince(date)
                    self.reportedTimes.add(Int(elapsed/60))
                }
                if count != 0 {
                    sumWait = Int(sumWait / count)
                    averageWaitTime = "   Average Wait: \(sumWait) mins"
                    self.averageWait.text = averageWaitTime
                }
                self.entries.reloadData()
            }
        }
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
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! WaitTimesTableViewCell
        
        cell.userName.text = userNames[indexPath.row] as? String
        cell.waitTime.text = "Wait time \(waitTimes[indexPath.row]) mins"
        cell.reportTime.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
        return cell
    }
    
    @IBAction func recordWaitPressed(_ sender: Any) {
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestaurantWait") as? RestaurantWaitTimeController {
            if let navigator = navigationController {
                viewController.restaurant = restaurant
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
}
