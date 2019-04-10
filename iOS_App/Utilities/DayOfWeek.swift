//
//  DayOfWeek.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/8/19.
//  Copyright © 2019 WaitTimes Inc. All rights reserved.
//

extension Date {
    func dayNumberOfWeek() -> Int? {
        let date = Calendar.current.date(byAdding: .hour, value: -2, to: self)
        let weekDay = Calendar.current.component(.weekday, from: date!)
        return weekDay
    }
}
