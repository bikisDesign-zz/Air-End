//
//  ViewController-Extension.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

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
    //MARK: MAPVIEW Methods
    
    func initalizeRequestWithDescriptor(nounDescriptor:String, location:CLLocation?) -> MKLocalSearchRequest? {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = nounDescriptor
        if let location = location?.coordinate {
            request.region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.01, 0.01))
            return request
        }
        return nil
    }
    
    func coordinateRegionForAnnotations(mapView:MKMapView) -> MKCoordinateRegion?{
        let allAnnotations = mapView.annotations
        var mapRect = MKMapRectNull
        for annotation in allAnnotations {
            let mapPointCoordinate = MKMapPointForCoordinate(annotation.coordinate)
            mapRect = MKMapRectUnion(mapRect, MKMapRectMake(mapPointCoordinate.x, mapPointCoordinate.y, 0, 0))
        }
        return MKCoordinateRegionForMapRect(mapRect)
    }
    
}
