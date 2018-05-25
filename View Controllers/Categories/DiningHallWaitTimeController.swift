//
//  RestaurantWaitTimeController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/12/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class DiningHallWaitTimeController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var diningHall = ""
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var busyField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = diningHall
        
        busyField.delegate = self
        busyField.addDoneButtonToKeyboard(myAction:  #selector(self.busyField.resignFirstResponder))
        
        comments.layer.borderColor = UIColor.lightGray.cgColor
        comments.layer.borderWidth = 0.5;
        comments.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

