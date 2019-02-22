//
//  BarWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class BarWaitTimeController: BasePickerWaitTimeController {
    
    @IBOutlet weak var coverField: UITextField!
    @IBOutlet weak var ratingField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Bars"
        
        coverField.delegate = self
        coverField.addDoneButtonToKeyboard(myAction:  #selector(self.coverField.resignFirstResponder))
        
        ratingField.delegate = self
        ratingField.addDoneButtonToKeyboard(myAction:  #selector(self.ratingField.resignFirstResponder))
    }
    
    override func addItemsToSubmit(items: [String : Any]) -> [String : Any] {
        var augmentedItems = items
        var cover = 0.0
        if(self.coverField.text != ""){
            cover = Double(self.coverField.text!)!
        }
        var rating = 1.0
        if(self.ratingField.text != ""){
            rating = Double(self.ratingField.text!)!
        }
        augmentedItems["WaitTime"] = NSString(format: "%d", self.waitTime)
        augmentedItems["Cover"] = cover
        augmentedItems["Rating"] = rating
        return augmentedItems
    }
}


