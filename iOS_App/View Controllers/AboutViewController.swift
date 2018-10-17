//
//  AboutViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 2/11/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }
    

    
    func customSetup() {
        if self.revealViewController() != nil {
            revealButtonItem.target = self.revealViewController()
            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.title = "About"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



