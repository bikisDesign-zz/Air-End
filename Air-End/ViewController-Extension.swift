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
    
    func showAlert(alertString: String) {
        let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .Cancel) { (alert) -> Void in
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func hideOverlay(isHidden:Bool, viewCollection:[UIView]){
        var alpha = CGFloat()
        alpha = isHidden ? 0.0 : 1.0
        for view in viewCollection {
            view.hidden = isHidden
            UIView.animateWithDuration(0.5, animations: {
                view.alpha = alpha
            })
        }
    }
    
    func addActivityIndicator(inout activityIndicator:UIActivityIndicatorView, vcView:UIView) {
        let activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.backgroundColor = view.backgroundColor
        activityIndicator.startAnimating()
        vcView.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator(inout activityIndicator:UIActivityIndicatorView) {
            activityIndicator.removeFromSuperview()
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
    
    func initializeRequest(source:MKMapItem, destination:MKMapItem) -> MKDirectionsRequest? {
        let request:MKDirectionsRequest = MKDirectionsRequest()
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        request.source = source
        request.destination = destination
        return request
    }
    
    func matchCoordinatesOfMapItemAndAnnoatation(annotation :MKAnnotation, mapItem: MKMapItem) -> Bool {
        let annotationCoordinate = annotation.coordinate
        let locationCoordinate = mapItem.placemark.coordinate
        if annotationCoordinate.latitude == locationCoordinate.latitude && annotationCoordinate.longitude == locationCoordinate.longitude {
            return true
        }
        return false
    }
    
    func searchForMapItemsMatchingNoun(noun:String?, userLocation:MKMapItem?, withCompletionHandler handler: ((mapItems:[MKMapItem]?) -> ())) {
        guard let descriptor = noun else {return}
        guard let request = initalizeRequestWithDescriptor(descriptor, location: userLocation?.placemark.location) else {return}
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
            guard let unSortedMapItems = response?.mapItems else {return}
            handler(mapItems: unSortedMapItems)
        })
    }
    
    func searchForFastestRouteWithDirections(directions:MKDirections, withCompletionHandler handler: (route:MKRoute?) -> ()){
        directions.calculateDirectionsWithCompletionHandler {(
            response: MKDirectionsResponse?,
            error: NSError?) in
            guard let routeResponse = response?.routes else {return}
            if let sourceToDestination:MKRoute = routeResponse.sort({$0.expectedTravelTime < $1.expectedTravelTime})[0] {
                handler(route: sourceToDestination)
            }
        }
    }
    
    func setRegionForUnionOfUserLocationAndTaskAnnotation(taskAnnotation:MKAnnotation, userLocation:CLLocation, mapView:MKMapView){
        mapView.addAnnotation(taskAnnotation)
        let userPoint = MKMapPointForCoordinate(userLocation.coordinate)
        let userLocationMapRect = MKMapRect(origin: userPoint, size: MKMapSize(width: 0.010, height: 0.010))
        let taskPoint = MKMapPointForCoordinate(taskAnnotation.coordinate)
        let taskLocationMapRect = MKMapRect(origin: taskPoint, size: MKMapSize(width: 0.010, height: 0.010))
        let mapRect = MKMapRectUnion(userLocationMapRect, taskLocationMapRect)
        let region = MKCoordinateRegionForMapRect(mapRect)
        mapView.setRegion(region, animated: true)
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
    
    func setMapRegionForMapItems(mapItemA:MKMapItem?, mapViewA:MKMapView?){
        guard let mapItem = mapItemA else {return}
        guard let mapView = mapViewA else {return}
        let newAnnotation = convertToAnnotationFromMapItem(mapItem)
        mapView.addAnnotation(newAnnotation)
        if let region = coordinateRegionForAnnotations(mapView){
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func sortMapItemsCloseToUserLocation(userLocation:CLLocation?, mapItems:[MKMapItem]) -> [MKMapItem]? {
        guard let currentLocation = userLocation else {return nil}
        return mapItems.sort({$0.placemark.location?.distanceFromLocation(currentLocation) < $1.placemark.location?.distanceFromLocation(currentLocation)})
    }
    
    
    func plotPolylineWithRoute(route: MKRoute, mapView:MKMapView) {
        mapView.addOverlay(route.polyline)
        let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                                                   route.polyline.boundingMapRect)
        mapView.setVisibleMapRect(polylineBoundingRect,
                                  edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                  animated: false)
    }
}
