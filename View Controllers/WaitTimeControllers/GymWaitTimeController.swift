//
//  BarWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class GymWaitTimeController: BaseWaitTimeController {
    
    @IBOutlet weak var busyField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        busyField.delegate = self
        busyField.addDoneButtonToKeyboard(myAction:  #selector(self.busyField.resignFirstResponder))
    }
}


