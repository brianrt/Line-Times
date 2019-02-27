//
//  BarWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import Cosmos

class BarWaitTimeController: BasePickerWaitTimeController  {
    
    @IBOutlet weak var coverField: UITextField!
    @IBOutlet weak var ratingsDisplay: CosmosView!
    @IBOutlet weak var ratingsSlider: UISlider!
    
    var rating = 2.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Bars"
        
        coverField.layer.addBorder(edge: .bottom, color: UIColor.gray, thickness: 1.0)
        coverField.delegate = self
        coverField.addDoneButtonToKeyboard(myAction:  #selector(self.coverField.resignFirstResponder))
    }
    
    @IBAction func ratingsSliderChanged(_ sender: UISlider) {
        rating = Double(ratingsSlider.value)
        ratingsDisplay.rating = rating
    }
    
    
    override func addItemsToSubmit(items: [String : Any]) -> [String : Any] {
        var augmentedItems = items
        var cover = 0.0
        if(self.coverField.text != ""){
            cover = Double(self.coverField.text!)!
        }
        augmentedItems["WaitTime"] = NSString(format: "%d", self.waitTime)
        augmentedItems["Cover"] = cover
        augmentedItems["Rating"] = rating
        return augmentedItems
    }
}


