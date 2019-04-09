//
//  SpecialsView.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/8/19.
//  Copyright © 2019 WaitTimes Inc. All rights reserved.
//

import FirebaseFunctions

class SpecialsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor=UIColor.white
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSpecials(barName: String) {
        let functions = Functions.functions()
        let today = getToday()
        let parameters = ["Bar": barName as Any, "Today": today as Any] as [String : Any]
        functions.httpsCallable("getSpecials").call(parameters) { (result, error) in
            if let todaysSpecials = (result?.data as? [String: Any])?["specials"] as? String {
                let dayLabel = UILabel()
                dayLabel.frame = CGRect(x: 20, y: 15, width: self.frame.width - 20, height: 40)
                dayLabel.text = today!
                dayLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 23)
                dayLabel.numberOfLines = 0
                dayLabel.sizeToFit()
                self.addSubview(dayLabel)
                
                let specialsLabel = UILabel()
                specialsLabel.frame = CGRect(x: 20, y: dayLabel.frame.maxY+30, width: self.frame.width - 20, height: self.frame.height-dayLabel.frame.maxY-30)
                specialsLabel.text = todaysSpecials
                specialsLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
                specialsLabel.numberOfLines = 0
                specialsLabel.sizeToFit()
                self.addSubview(specialsLabel)
            }
        }
    }
    
    func getToday() -> String? {
        let dates = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return dates[Date().dayNumberOfWeek()!]
    }
}
