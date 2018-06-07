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
    
    var userNames: NSMutableArray!
    var entriesList: NSMutableArray!
    var reportedTimes: NSMutableArray!
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
    
    override func viewWillAppear(_ animated: Bool) {
        userNames = []
        entriesList = []
        reportedTimes = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchEntries(){}
    
    //Subclasses need to implement this
    func assignAverageLabel(){}
    
    
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
        cell.waitTime.text = "How Busy \(entriesList[indexPath.row])/10"
        cell.reportTime.text = "Reported \(reportedTimes[indexPath.row]) mins ago"
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
