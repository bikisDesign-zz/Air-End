//
//  ListVC-LocationExtension.swift
//  Air-End
//
//  Created by Aaron B on 3/22/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension ListVC: CLLocationManagerDelegate{
    
    func determineLocationAuthorizationStatus() -> (Bool) {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            return false
        case .Denied:
            locationManager.requestWhenInUseAuthorization()
            return false
        case .AuthorizedAlways:
            locationManager.startUpdatingLocation()
            return true
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            return true
        default:
            assertionFailure("received unexpected authorization status")
        }
        return false
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // check if denied or authed when in use if so prompt
        switch status {
            //        case .Denied:
            // prompt that we need it to funcion
            //        case .AuthorizedWhenInUse:
            // do stuff
            // do stuff
        default:
            break
            //            assertionFailure("received unexpected authorization status")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newUserLocation = locations.first as CLLocation? {
            currentLocation = newUserLocation
            locationManager.stopUpdatingLocation()
        }
    }
    
    func findCloseLocationsMatchingNoun(nounDescriptor:String) {
        if let request = initalizeRequestWithDescriptor(nounDescriptor, location: currentLocation){
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
                if let mapItems = response?.mapItems {
                    let sortedCloseTasks = mapItems.sort({$0.placemark.location?.distanceFromLocation(self.currentLocation!) < $1.placemark.location?.distanceFromLocation(self.currentLocation!)})
                    self.closeMapItems[nounDescriptor] = sortedCloseTasks
                    self.tableView.reloadData()
                }
                else {
                    print("didn't find any close tasks")
                }})}
        else{
            print("could not locate the user")}
    }
    
    func findClosestLocationNameForTask(task:Task) -> String? {
        if let noun = task.hashtag?.descriptor {
            let mapItems = closeMapItems[noun]
            return mapItems?.first?.placemark.name
        }
        else {
            return "No close locations for this task"
        }
    }
}