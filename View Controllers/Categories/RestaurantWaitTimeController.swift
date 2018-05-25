//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class RestaurantWaitTimeController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var waitTimes = [0, 5, 10, 15, 20, 25, 30]
    var restaurant = ""
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var costField: UITextField!
    @IBOutlet weak var comments: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = restaurant
        timePicker.delegate = self
        timePicker.dataSource = self
        costField.delegate = self
        costField.addDoneButtonToKeyboard(myAction:  #selector(self.costField.resignFirstResponder))
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5
        comments.delegate = self
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
