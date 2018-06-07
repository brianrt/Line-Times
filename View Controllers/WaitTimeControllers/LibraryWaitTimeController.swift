//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class LibraryWaitTimeController: BaseWaitTimeController {
    
    @IBOutlet weak var busyField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        busyField.delegate = self
        busyField.addDoneButtonToKeyboard(myAction:  #selector(self.busyField.resignFirstResponder))
        
    }
}

