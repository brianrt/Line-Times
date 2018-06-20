//
//  BarController.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/24/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class LibraryController: BaseCategoryController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryType = "Libraries"
        waitIdentifier = "LibraryWait"
        
        //Setup nib for custom cells
        let nib = UINib(nibName: "EntryTwoRowTableViewCell", bundle: nil)
        entries.register(nib, forCellReuseIdentifier: "EntryTwoCell")
        fetchEntries()
    }
}
