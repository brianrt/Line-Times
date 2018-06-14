//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BarController: BaseCategoryController {

    @IBOutlet weak var cover: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Bars"
        waitIdentifier = "BarWait"
        cover.layer.borderColor = UIColor.lightGray.cgColor
        cover.layer.borderWidth = 0.5;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEntries()
    }
    
    override func fetchEntries(){
        let covers: NSMutableArray = []
        ref.child("Categories").child(categoryType).child(name).child("Entries").queryOrdered(byChild: "Time Stamp").observeSingleEvent(of: .value) { (snapshot) in
            if(snapshot.value != nil){
                self.averageValue = 0
                var count = 0
                for child in (snapshot.children.allObjects as! [DataSnapshot]).reversed() {
                    let entry = child.value as? NSDictionary
                    self.userNames.add(entry!["Username"]!)
                    covers.add(entry!["Cover"]!)
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
                    
                    //Calculate mode of cover
                    let countedSet = NSCountedSet(array: covers as! [Any])
                    let coverValue = countedSet.max { countedSet.count(for: $0) < countedSet.count(for: $1) }
                    self.cover.text = String(format:"   Cover: $%.2f", coverValue as! Double)
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

