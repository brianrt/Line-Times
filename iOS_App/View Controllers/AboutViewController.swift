//
//  AboutViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 2/11/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var aboutText: UILabel!
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
        
        //Add shadows to nav bar
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        //Adjust y of text
        let topY = self.navigationController?.navigationBar.frame.maxY
        aboutText.frame.origin.y = topY! - 40
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



