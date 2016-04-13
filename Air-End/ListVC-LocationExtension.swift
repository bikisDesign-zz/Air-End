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
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            taskManager.readAllTasks { (tasks) -> () in
                self.tasks = tasks
                for task in tasks! {
                    self.findClosestMapItemMatchingTask(task, userLocation: newUserLocation)
                }
            }
        }
    }
    
    func findClosestMapItemMatchingTask(task:Task, userLocation:CLLocation) {
        print("finding Closest Task")
        guard let descriptor = task.hashtag?.descriptor else {return print("this task doesn't have a descriptor")}
        guard let request = initalizeRequestWithDescriptor(descriptor, location: userLocation) else {return showAlert("We couldn't locate you! Please try again.")}
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
            guard let mapItems = response?.mapItems else { return print("couldn't find any close mapItems matching \(descriptor)")}
            
            let sortedCloseTasks = mapItems.sort({$0.placemark.location?.distanceFromLocation(userLocation) < $1.placemark.location?.distanceFromLocation(userLocation)})
            self.closeMapItems[task.name] = sortedCloseTasks.first!
            if let distanceFromUser = sortedCloseTasks.first?.placemark.location?.distanceFromLocation(userLocation) {
                try! uiRealm.write({
                    task.distanceFromUser = distanceFromUser
                })
            }
        })
    }
    
    //    func findClosestLocationNameForTask(task:Task) -> String? {
    //        if let noun = task.hashtag?.descriptor {
    //            let mapItems = closeMapItems[noun]
    //            return mapItems?.first?.placemark.name
    //        }
    //        else {
    //            return "No close locations for this task"
    //        }
    //    }
}