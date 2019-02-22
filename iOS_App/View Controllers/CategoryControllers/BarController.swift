//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Cosmos

class BarController: BaseCategoryController {

    @IBOutlet weak var coverLabel: UILabel!
    @IBOutlet weak var coverAmount: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    
    var covers: NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Bars"
        waitIdentifier = "BarWait"
        
        
        //Setup nib for custom cells
        let nib = UINib(nibName: "EntryThreeRowTableViewCell", bundle: nil)
        entries.register(nib, forCellReuseIdentifier: "EntryThreeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEntries()
    }
    
    override func initLists() {
        super.initLists()
        self.covers = []
    }
    
    override func setHeights() {
        super.setHeights()
        coverLabel.frame.origin.y = entryLabel.frame.origin.y
        coverAmount.frame.origin.y = averageLabel.frame.origin.y
        ratings.frame.origin.y = averageLabel.frame.maxY + 5
        
        //Overriding from super functio
        divider.frame.origin.y = ratings.frame.maxY + 20
        entries.frame.origin.y = divider.frame.origin.y + divider.frame.height
        entries.frame.size.height = self.view.frame.height - entries.frame.origin.y
    }
    
    override func fetchEntries(){
        ref.child("Categories").child(categoryType).child(name).child("Entries").queryOrdered(byChild: "Time Stamp").observe(.value) { (snapshot) in
            self.initLists()
            for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                let entry = child.value as? NSDictionary
                self.userNames.add(entry!["Username"]!)
                self.entriesList.add(entry!["Wait Time"]!)
                self.covers.add(entry!["Cover"]!)
                
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
        
        ref.child("Categories").child(categoryType).child(name).child("Most Frequent Cover").observe(.value) { (snapshot) in
            let cover = snapshot.value as! String
            if(cover == "N/A"){
                self.coverAmount.text = "n/a"
            } else {
                self.coverAmount.text = "$\(cover)"
            }
        }
        
        ref.child("Categories").child(categoryType).child(name).child("Average Rating").observe(.value) { (snapshot) in
            let rating = snapshot.value as! String
            self.ratings.rating = Double(rating)!
        }
        
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryThreeCell", for: indexPath) as! EntryThreeRowTableViewCell
        
        cell.mainLabel.text = userNames[indexPath.row] as? String
        cell.firstInfoLabel.text = "\(entriesList[indexPath.row]) min"
        cell.secondInfoLabel.text = "$\(covers[indexPath.row])"
        cell.thirdInfoLabel.text = "\(reportedTimes[indexPath.row]) min ago"
        cell.thirdInfoLabel.textColor = UIColor.lightGray
        return cell
    }
    
    
}

