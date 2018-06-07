//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

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

