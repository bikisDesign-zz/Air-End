//
//  ViewController-Conversions-Extension.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

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
    
    func convertToAnnotationFromMapItem(mapItem:MKMapItem) -> MKPointAnnotation {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.title = mapItem.name
        newAnnotation.coordinate = (mapItem.placemark.location?.coordinate)!
        return newAnnotation
    }
    
    func convertAddressFromPlacemark(placemark: MKPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joinWithSeparator(", ")
    }
}