//
//  User.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    let username: String
    let entryCount: Int
    
    init(uid: String, email: String, username: String, entryCount: Int) {
        self.uid = uid
        self.email = email
        self.username = username
        self.entryCount = entryCount
    }
}
