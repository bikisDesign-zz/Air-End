//
//  ColoredDatePicker.swift
//  Air-End
//
//  Created by Aaron B on 4/5/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit

class ColoredDatePicker: UIDatePicker {
        var changed = false
        override func addSubview(view: UIView) {
            if !changed {
                changed = true
                self.setValue(UIColor.whiteColor(), forKey: "textColor")
            }
            super.addSubview(view)
}
}