//
//  MapVC-SegmentedControl-Extension.swift
//  Air-End
//
//  Created by Aaron B on 4/2/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

extension MapVC {
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentAllTasks()
        case 1:
            segmentCloseTasks()
        case 2:
            segmentEnRoute()
        default:
            assertionFailure("received extroneous input from segemented control")
        }
    }
    
    
    func segmentAllTasks(){
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField])
        taskManager.readAllTasks(withCompletionHandler: { (tasks) in
            guard let allTasks = tasks else {return}
            self.tasks = allTasks
            for task in self.tasks! {
                guard let descriptor = task.hashtag?.descriptor else {return}
                self.searchForMapItemsMatchingNoun(descriptor, withCompletionHandler: { (mapItems) -> () in
                    // find the closest map item matching this task
                    if let sortedMapItems = self.sortMapItemsCloseToUserLocation(self.taskMapView.userLocation.location, mapItems: mapItems){
                        guard let closestMapItem = sortedMapItems.first else {return}
                        self.taskLocations = [closestMapItem]
                        self.setMapRegionForMapItems(sortedMapItems.first, mapViewA: self.taskMapView)
                    }
                })
            }
        })
    }
    
    
    func segmentCloseTasks(){
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField])
        //        if closeMapItems.count > 0 {
        //                //then they are already sorted
        //            for mapItem in closeMapItems {
        //             // search through map items and find ones that are within a geofence
        //             // have ui available to route all of them
        //            }
        //            }
    }
    
    func segmentEnRoute() {
        hideOverlay(false, viewCollection: [enRouteView, destinationTextField])
        checkDestinationUI(false)
    }
    
    
    
    func searchForMapItemsMatchingNoun(noun:String?, withCompletionHandler handler: ((mapItems:[MKMapItem]) -> ()?)) {
        guard let descriptor = noun else {return}
        guard let request = initalizeRequestWithDescriptor(descriptor, location: userLocation?.placemark.location) else {return}
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
            guard let unSortedMapItems = response?.mapItems else {return print("couldn't find any mapItems matching \(noun)")}
            handler(mapItems: unSortedMapItems)
        })
    }
}