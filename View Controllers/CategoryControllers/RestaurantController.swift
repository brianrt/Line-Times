//
//  LocationController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 1/2/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RestaurantController: BaseCategoryController {

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Restaurants"
        waitIdentifier = "RestaurantWait"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEntries()
    }
    
    override func fetchEntries(){
        ref.child("Categories").child(categoryType).child(name).child("Entries").queryOrdered(byChild: "Time Stamp").observeSingleEvent(of: .value) { (snapshot) in
            if(snapshot.value != nil){
                self.averageValue = 0
                var count = 0
                for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                    let entry = child.value as? NSDictionary
                    self.userNames.add(entry!["Username"]!)
                    let wait = entry!["Wait Time"]!
                    self.entriesList.add(wait)
                    self.averageValue += Int(wait as! String)!
                    count += 1
                    
                    //Convert timestamp to time since in minutes
                    let timeStamp = entry!["Time Stamp"] as! Double
                    let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
                    let elapsed = Date().timeIntervalSince(date)
                    self.reportedTimes.add(Int(elapsed/60))
                }
                if count != 0 {
                    self.averageValue = Int(self.averageValue / count)
                    self.assignAverageLabel()
                }
                self.entries.reloadData()
            }
        }
    }
    
    override func assignAverageLabel(){
        self.averageLabel.text = "   Average Wait: \(self.averageValue) mins"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as! WaitTimesTableViewCell
        
        cell.userName.text = userNames[indexPath.row] as? String
        cell.waitTime.text = "Wait time \(entriesList[indexPath.row]) mins"
        cell.reportTime.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
        return cell
    }
    
}
