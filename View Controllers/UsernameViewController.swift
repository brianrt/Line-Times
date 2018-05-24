//
//  UsernameViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class UsernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var userNameText: UITextField!
    
    var defaults: UserDefaults!
    var username: String!
    
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
        defaults = UserDefaults.standard
        if defaults.object(forKey: "username") != nil {
            username = defaults.object(forKey: "username") as! String
            setCanEdit()
        } else {
            setCanSave()
        }
        edit.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        save.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        userNameText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCanEdit() {
        userNameLabel.isHidden = false
        edit.isHidden = false
        userNameText.isHidden = true
        save.isHidden = true
        userNameLabel.text = username
    }
    
    func setCanSave() {
        userNameLabel.isHidden = true
        edit.isHidden = true
        userNameText.isHidden = false
        save.isHidden = false
        if username != nil && username.count > 0{
            userNameText.text = username
        }
    }
    
    @objc func editPressed(sender: UIButton!) {
        setCanSave()
    }
    
    @objc func savePressed(sender: UIButton!) {
        username = userNameText.text
        defaults.set(username, forKey: "username")
        userNameText.endEditing(true)
        setCanEdit()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        savePressed(sender: nil)
        return true
    }
}
