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
        
         //Setup nib for custom cells
        let nib = UINib(nibName: "EntryTwoRowTableViewCell", bundle: nil)
        entries.register(nib, forCellReuseIdentifier: "EntryTwoCell")
        fetchEntries()
    }
    
    override func fetchEntries(){
        ref.child("Categories").child(categoryType).child(name).child("Entries").queryOrdered(byChild: "Time Stamp").observe(.value) { (snapshot) in
            self.initLists()
            for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                let entry = child.value as? NSDictionary
                self.userNames.add(entry!["Username"]!)
                self.entriesList.add(entry!["Wait Time"]!)
                self.comments.add(entry!["Comment"]!)
                
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
    
    override func assignAverageLabel(){
        ref.child("Categories").child(categoryType).child(name).child("Average Wait Time").observe(.value) { (snapshot) in
            let averageWaitTime = snapshot.value as! String
            if(averageWaitTime == "N/A"){
                self.averageLabel.text = "n/a"
            } else {
                self.averageLabel.text = "\(averageWaitTime) min"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTwoCell", for: indexPath) as! EntryTwoRowTableViewCell
        
        cell.mainLabel.text = userNames[indexPath.row] as? String
        cell.firstInfoLabel.text = "\(entriesList[indexPath.row]) min"
        cell.rightArrow.isHidden = true
        cell.secondInfoLabel.text = "\(reportedTimes[indexPath.row]) min ago"
        cell.secondInfoLabel.frame.size.width = 150
        cell.secondInfoLabel.textColor = UIColor.lightGray
        return cell
    }
    
}
