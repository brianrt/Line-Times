//
//  FeedbackViewController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 7/13/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFunctions

class PrizesViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var revealButtonItem: UIBarButtonItem!
    @IBOutlet weak var totalPoints: UILabel!
    @IBOutlet weak var raffleEnds: UILabel!
    @IBOutlet weak var amazonLabelTop: UILabel!
    @IBOutlet weak var amazonImage: UIImageView!
    @IBOutlet weak var visaLabelTop: UILabel!
    @IBOutlet weak var visaImage: UIImageView!
    @IBOutlet weak var amazonEntriesLabel: UILabel!
    @IBOutlet weak var visaEntriesLabel: UILabel!
    @IBOutlet weak var amazonEntries: UITextField!
    @IBOutlet weak var visaEntries: UITextField!
    @IBOutlet weak var saveEntries: UIButton!
    
    var ref = Database.database().reference()
    var defaults: UserDefaults!
    var sv: UIView!
    var viewShift: CGFloat = 0.0
    var editingVisa = false
    var keyboardShowing = false
    
    //Get info from Firebase
    var entryCount = 0
    var amazonPoints = 0
    var visaPoints = 0
    var raffleEndsText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customSetup()
    }    
    
    func customSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        
        if self.revealViewController() != nil {
            revealButtonItem.target = self.revealViewController()
            revealButtonItem.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        defaults = UserDefaults.standard
        
        self.title = "Prizes"
        //Add shadows to nav bar
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 4.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Modify the text boxes
        amazonEntries.delegate = self
        amazonEntries.addDoneButtonToKeyboard(myAction:  #selector(self.amazonEntries.resignFirstResponder))
        visaEntries.delegate = self
        visaEntries.addDoneButtonToKeyboard(myAction:  #selector(self.visaEntries.resignFirstResponder))
        
        //Add shadows to gift card
        amazonImage.layer.shadowColor = UIColor(red: 0.23, green: 0.44, blue: 1, alpha: 1.0).cgColor
        amazonImage.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        amazonImage.layer.shadowRadius = 4.0
        amazonImage.layer.shadowOpacity = 1.0
        amazonImage.layer.masksToBounds = false
        
        visaImage.layer.shadowColor = UIColor(red: 0.23, green: 0.44, blue: 1, alpha: 1.0).cgColor
        visaImage.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        visaImage.layer.shadowRadius = 4.0
        visaImage.layer.shadowOpacity = 1.0
        visaImage.layer.masksToBounds = false
        
        //Save Entries button
        saveEntries.layer.cornerRadius = 10
        saveEntries.layer.borderColor = UIColor.black.cgColor
        saveEntries.layer.borderWidth = 1.0
        
        //Set heights and layout
        totalPoints.frame = CGRect(x: 0, y: 5, width: view.frame.width, height: 30)
        raffleEnds.frame = CGRect(x: 0, y: totalPoints.frame.height, width: view.frame.width, height: 30)
        let giftFrame = amazonImage.frame
        amazonLabelTop.frame = CGRect(x: 10, y: raffleEnds.frame.maxY + 20, width: view.frame.width-20, height: 25)
        amazonImage.frame = CGRect(x: 10, y: amazonLabelTop.frame.maxY+5, width: giftFrame.width, height: giftFrame.height)
        amazonEntriesLabel.frame = CGRect(x: (view.frame.width + amazonImage.frame.maxX)/2  - amazonEntriesLabel.frame.width / 2 , y: amazonImage.frame.minY + 30, width: amazonEntriesLabel.frame.width, height: 25)
        amazonEntries.frame = CGRect(x: (amazonEntriesLabel.frame.minX + amazonEntriesLabel.frame.maxX)/2 - (amazonEntries.frame.width/2), y: amazonEntriesLabel.frame.maxY+7, width: 50, height: 30)
        visaLabelTop.frame = CGRect(x: 10 , y: amazonImage.frame.maxY + 30, width: giftFrame.width, height: 25)
        visaImage.frame = CGRect(x: 10, y: visaLabelTop.frame.maxY+5, width: giftFrame.width, height: giftFrame.height)
        visaEntriesLabel.frame = CGRect(x: amazonEntriesLabel.frame.minX , y: visaImage.frame.minY + 30, width: visaEntriesLabel.frame.width, height: 25)
        visaEntries.frame = CGRect(x: amazonEntries.frame.minX, y: visaEntriesLabel.frame.maxY+7, width: 50, height: 30)
        saveEntries.frame = CGRect(x: view.frame.width/2 - saveEntries.frame.width/2, y: min(visaImage.frame.maxY + 180, view.frame.height - saveEntries.frame.height - 15), width: 130, height: saveEntries.frame.height)
        
        
        
        getRaffleInfo()
    }
    
    func getRaffleInfo() {
        sv = UIViewController.displaySpinner(onView: self.view)
        let functions = Functions.functions()
        let userID = self.defaults.object(forKey: "userId") as? String
        let parameters = ["userID": userID as Any] as [String : Any]
        functions.httpsCallable("getRaffleInfo").call(parameters) { (result, error) in
            if let data = result?.data as? [String: Any]{
                self.entryCount = data["entryCount"] as! Int
                self.amazonPoints = data["amazonPoints"] as! Int
                self.visaPoints = data["visaPoints"] as! Int
                self.raffleEndsText = data["raffleEnds"] as? String
                
                //Set UI
                self.totalPoints.text = "Your Total Points: \(self.entryCount)"
                self.raffleEnds.text = "Giveaway ends at 8 pm on " + self.raffleEndsText
                self.amazonEntries.text = "\(self.amazonPoints)"
                self.visaEntries.text = "\(self.visaPoints)"
                
                //Check for new raffle
                let cachedRaffleEndValue = self.defaults.object(forKey: "cachedRaffleEnd")
                if (cachedRaffleEndValue == nil) {
                    self.defaults.set(self.raffleEndsText, forKey: "cachedRaffleEnd")
                } else {
                    let cachedRaffleEnd = cachedRaffleEndValue as? String
                    if (cachedRaffleEnd != self.raffleEndsText) {
                        //Beginning a new raffle week
                        self.defaults.set(self.raffleEndsText, forKey: "cachedRaffleEnd")
                        self.displayAlert(title: "New Giveaway Has Started", message: "A new giveaway has now started for the week. Please check your email to see if you won last weeks giveaway!")
                    }
                }
            }
            UIViewController.removeSpinner(spinner: self.sv)
        }
    }
    
    //Dismiss Keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func displayRules(_ sender: Any) {
        displayAlert(title: "Rules", message: "Use your points to enter our weekly drawing for these two gift cards! The more you contribute, the higher your chances of winning. Use your points now or save them for next week's drawing. Edit your entries anytime before the giveaway deadline at the top.")
    }
    
    //Move screen up and down when editing and done editing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.isEqual(self.visaEntries)) {
            editingVisa = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if editingVisa {
            UIView.animate(withDuration: 0.25) {
                self.view.frame.origin.y += self.viewShift
            }
        }
        editingVisa = false
        keyboardShowing = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if editingVisa && !keyboardShowing {
            keyboardShowing = true
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                viewShift = max(0,visaImage.frame.maxY - (view.frame.height - keyboardHeight)) + 5
                
                UIView.animate(withDuration: 0.25) {
                    self.view.frame.origin.y -= self.viewShift
                }
            }
        }
    }
    
    @IBAction func savedEntriesPressed(_ sender: Any) {
        sv = UIViewController.displaySpinner(onView: self.view)
        let functions = Functions.functions()
        let userID = self.defaults.object(forKey: "userId") as? String
        let amazonPoints = Int(amazonEntries.text!)
        let visaPoints = Int(visaEntries.text!)
        let parameters = ["userID": userID as Any, "amazonPoints": amazonPoints as Any, "visaPoints": visaPoints as Any] as [String : Any]
        functions.httpsCallable("updateRaffleContributions").call(parameters) { (result, error) in
            if let data = result?.data as? [String: Any]{
                let title = data["title"] as? String
                let message = data["message"] as? String
                self.amazonPoints = data["amazonPoints"] as! Int
                self.visaPoints = data["visaPoints"] as! Int
                
                //Set UI
                self.amazonEntries.text = "\(self.amazonPoints)"
                self.visaEntries.text = "\(self.visaPoints)"
                
                //Display popup
                self.displayAlert(title: title!, message: message!)
            }
            UIViewController.removeSpinner(spinner: self.sv)
        }
    }
}
