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
        categoryType = "Libraries"
        busyField.delegate = self
        busyField.addDoneButtonToKeyboard(myAction:  #selector(self.busyField.resignFirstResponder))
        
    }
    
    override func addItemsToSubmit(items: [String : Any]) -> [String : Any] {
        var augmentedItems = items
        var busyRating = 0.0
        if(self.busyField.text != ""){
            busyRating = Double(self.busyField.text!)!
        }
        augmentedItems["BusyRating"] = busyRating
        return augmentedItems
    }
}

