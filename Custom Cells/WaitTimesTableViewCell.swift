//
//  WaitTimesTableViewCell.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class WaitTimesTableViewCell: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var waitTime: UILabel!
    @IBOutlet weak var reportTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}
