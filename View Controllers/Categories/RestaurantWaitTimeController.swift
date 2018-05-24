//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class RestaurantWaitTimeController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var waitTimes = [0, 5, 10, 15, 20, 25, 30]
    var restaurant = ""
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var comments: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant
        timePicker.delegate = self
        timePicker.dataSource = self
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return waitTimes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(waitTimes[row]) mins"
    }
    
}

