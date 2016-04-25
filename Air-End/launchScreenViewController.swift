//
//  launchScreenViewController.swift
//  Mango
//
//  Created by Aaron B on 4/22/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit

class launchScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUPUI()
    }
    func setUPUI(){
        view.backgroundColor = Theme.Colors.BackgroundColor.color
    }
}
