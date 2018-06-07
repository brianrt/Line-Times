//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class RestaurantWaitTimeController: BasePickerWaitTimeController {
    
    
    
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var submit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Restaurants"
        
        costField.delegate = self
        costField.addDoneButtonToKeyboard(myAction:  #selector(self.costField.resignFirstResponder))
    }
    
    override func augmentItemsToSubmit(items: [String : Any]) -> [String : Any] {
        var augmentedItems = items
        var cost = "0.00"
        if(self.costField.text != ""){
            cost = self.costField.text!
        }
        augmentedItems["Wait Time"] = NSString(format: "%d", self.waitTime)
        augmentedItems["Cost"] = cost
        return augmentedItems
    }

}
