//
//  BasePickerWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 6/7/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import CoreLocation

class BasePickerWaitTimeController: BaseWaitTimeController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var waitTimes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    var waitTime = 0
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.layer.borderWidth = 0.5
        timePicker.layer.borderColor = UIColor.lightGray.cgColor
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        waitTime = waitTimes[row]
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y -= self.view.frame.height/3.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y += self.view.frame.height/3.0
        }
    }
    
}
