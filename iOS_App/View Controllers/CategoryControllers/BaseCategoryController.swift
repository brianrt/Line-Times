//
//  BaseCategoryController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 6/7/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BaseCategoryController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var userNames: NSMutableArray = []
    var entriesList: NSMutableArray = []
    var reportedTimes: NSMutableArray = []
    var comments: NSMutableArray = []
    var name = ""
    var ref = Database.database().reference()
    var averageValue = 0
    var categoryType = ""
    var waitIdentifier = ""
    var commentView: CommentView!
    var previousIndexRow = 0
    
    @IBOutlet var entries: UITableView!
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var recordEntry: UIButton!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        venueName.text = name
        entries.delegate = self
        entries.dataSource = self
        setupLongPressGesture()
        entries.allowsSelection = false
        
//        averageLabel.layer.borderColor = UIColor.lightGray.cgColor
//        averageLabel.layer.borderWidth = 0.5
        

        
        //Add button shadow
        recordEntry.backgroundColor = UIColor.white
        recordEntry.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        recordEntry.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        recordEntry.layer.masksToBounds = false
        recordEntry.layer.shadowRadius = 2.0
        recordEntry.layer.shadowOpacity = 1.0
        recordEntry.layer.cornerRadius = 15
        recordEntry.layer.borderColor = UIColor.black.cgColor
        recordEntry.layer.borderWidth = 1.0
        
        // For iPhone 5
        let buttonFrame = recordEntry.frame
        if (buttonFrame.maxX > view.frame.width) {
            recordEntry.frame = CGRect(x: buttonFrame.minX-30, y: buttonFrame.minY, width: buttonFrame.width-10, height: buttonFrame.height)
        }
        
        
        divider.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor(red: 0.13, green: 0.46, blue: 0.85, alpha: 1.0), thickness: 2.0)
        setHeights()
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.1
        longPressGesture.delegate = self
        self.entries.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: self.entries)
        if let indexPath = entries.indexPathForRow(at: touchPoint) {
            if (gestureRecognizer.state == .began) {
                let height: CGFloat = 80
                self.commentView = CommentView(frame: CGRect(x: 20, y: touchPoint.y+height-30, width: view.frame.width-40, height: height))
                commentView.setComment(comment: comments[indexPath.row] as! String)
                previousIndexRow = indexPath.row
                self.view.addSubview(commentView);
            } else if (gestureRecognizer.state == .ended) {
                if (commentView != nil) {
                    self.commentView.removeFromSuperview()
                }
            } else if (gestureRecognizer.state == .changed) {
                if (indexPath.row != previousIndexRow) {
                    previousIndexRow = indexPath.row
                    let height: CGFloat = 80
                    if (commentView != nil) {
                        self.commentView.removeFromSuperview()
                    }
                    self.commentView = CommentView(frame: CGRect(x: 20, y: touchPoint.y+height-30, width: view.frame.width-40, height: height))
                    commentView.setComment(comment: comments[indexPath.row] as! String)
                    self.view.addSubview(commentView);
                }
            }
        } else if (commentView != nil) {
            commentView.removeFromSuperview()
        }
    }
    
    func initLists() {
        userNames = []
        entriesList = []
        reportedTimes = []
        comments = []
    }
    
    func setHeights(){
        let topY = self.navigationController?.navigationBar.frame.maxY
        venueName.frame.origin.y = topY! - 40
        entryLabel.frame.origin.y = venueName.frame.maxY + 30
        recordEntry.frame.origin.y = entryLabel.frame.origin.y
        averageLabel.frame.origin.y = entryLabel.frame.origin.y + entryLabel.frame.height
        divider.frame.origin.y = averageLabel.frame.maxY + 30
        entries.frame.origin.y = divider.frame.origin.y + divider.frame.height
        entries.frame.size.height = self.view.frame.height - entries.frame.origin.y
        
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
    
    //The standard assignAverageLabel function for Library, Dining Hall, Gym
    func assignAverageLabel(){
        ref.child("Categories").child(categoryType).child(name).child("Average Busy Rating").observe(.value) { (snapshot) in
            let averageBusyRating = snapshot.value as! String
            if(averageBusyRating == "N/A"){
                self.averageLabel.text = "n/a"
            } else {
                self.averageLabel.text = "\(averageBusyRating)/10"
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
    
//    //Display comment when pressed
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//
//    }
    
    //The standard cellForRowAt function for Library, Dining Hall, Gym
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryTwoCell", for: indexPath) as! EntryTwoRowTableViewCell
        
        cell.mainLabel.text = userNames[indexPath.row] as? String
        cell.firstInfoLabel.text = "\(entriesList[indexPath.row])/10"
        cell.secondInfoLabel.text = "\(reportedTimes[indexPath.row]) min ago"
        cell.secondInfoLabel.textColor = UIColor.lightGray
        cell.secondInfoLabel.frame.size.width = 150
        cell.rightArrow.isHidden = true
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
