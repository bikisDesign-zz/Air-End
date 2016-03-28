//
//  ViewController-Extension.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
extension UIViewController {
    func generateRandomPassCode() -> String {
        let alphaNumerial = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678910"
        var finalString = ""
        for _ in 0...2 {
            let randomNumber = arc4random_uniform(UInt32(alphaNumerial.characters.count))
            let index = alphaNumerial.startIndex.advancedBy((Int(randomNumber)))
            let str = alphaNumerial[index]
            finalString = "\(finalString)\(str)"
        }
        return finalString
    }
    
    func allTextFieldsAreFilled(textFields:[UITextField]) -> Bool{
        var allFields = false
        for tF in textFields {
            if tF.text == "" || tF.text == nil  {
                animateTextField(tF) }
            else {
                allFields = true
            }
        }
        if allFields == false {
            return false
        }
        return true
    }
    
    func animateTextField(textField:UITextField){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            textField.backgroundColor = UIColor.redColor()
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
//                    textField.backgroundColor = Theme.Colors.ForegroundColor.color
                    }, completion: nil)
        }
    }
}
