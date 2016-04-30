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
            segmentEnRoute()
        default:
            assertionFailure("received extroneous input from segemented control")
        }
    }
    
    func segmentAllTasks(){
        getLocation()
        guidanceEnabled = true
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField])
    }
    
    func segmentEnRoute() {
        guidanceEnabled = false
        hideOverlay(false, viewCollection: [enRouteView, destinationTextField])
        checkDestinationUI(false)
    }
}