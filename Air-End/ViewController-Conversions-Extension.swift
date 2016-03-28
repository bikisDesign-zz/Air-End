//
//  ViewController-Conversions-Extension.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
extension UIViewController {
    func convertBooltoInt(bool:Bool) -> Int {
        return bool == true ? 1 : 0
    }
    
    func convertNSDateToString(date:NSDate) -> String {
        let formater = NSDateFormatter()
        formater.dateFormat = "dd/MM"
        return formater.stringFromDate(date)
    }
    
    func convertStringToNSDate(date:String) -> NSDate {
        let formater = NSDateFormatter()
        formater.dateFormat = "dd/MM"
        return formater.dateFromString(date)!
    }
}