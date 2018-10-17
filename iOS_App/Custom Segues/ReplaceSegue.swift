//
//  replaceSegue.swift
//  Wait-Times
//
//  Created by Brian Thompson on 5/25/18.
//  Copyright © 2018 WaitTimes Inc. All rights reserved.
//

import UIKit

class ReplaceSegue: UIStoryboardSegue {
    override func perform() {
        var controllers = source.navigationController?.viewControllers
        controllers![(controllers?.count)!-1] = destination
        source.navigationController?.setViewControllers(controllers!, animated: true)
    }
}
