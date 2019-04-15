//
//  PrivacyPolicy.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/14/19.
//  Copyright © 2019 WaitTimes Inc. All rights reserved.
//
import UIKit


class PrivacyPolicy: UIViewController {
    
    @IBOutlet weak var text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        text.isEditable = false
        self.title = "Privacy Policy"
        
    }
}
