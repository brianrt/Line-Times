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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Restaurants"
    }
    
    override func addItemsToSubmit(items: [String : Any]) -> [String : Any] {
        var augmentedItems = items
        augmentedItems["WaitTime"] = NSString(format: "%d", self.waitTime)
        return augmentedItems
    }

}
