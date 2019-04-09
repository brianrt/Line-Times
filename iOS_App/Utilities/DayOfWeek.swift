//
//  DayOfWeek.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/8/19.
//  Copyright © 2019 WaitTimes Inc. All rights reserved.
//

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
