//
//  MapVC-Guidance-ExtensionViewController.swift
//  Air-End
//
//  Created by Aaron B on 4/11/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit
extension MapVC {
    @IBAction func beginGuidance(sender: UIButton) {
        setUpTurnByTurnUI()
        guidanceButton.hidden = true
        guidanceButton.alpha = 0.0
        taskMapView.removeOverlays(taskMapView.overlays)
        taskMapView.removeAnnotations(taskMapView.annotations)
        setUpGuidanceUI(true)
        userSelectingAdditionalRoutes = false
        for taskLocation in taskLocations {
            taskMapView.addAnnotation(convertToAnnotationFromMapItem(taskLocation))
        }
        let filteredGuidance = guidances.filter{($0.wasSelectedForFinalRoute == true)}
        guidances = filteredGuidance
        let userGuidance = Guidance(index: guidances.count, sourceRoute:MKRoute() , destinationRoute: MKRoute(), destinationMapItem: userLocation)
        guidances.sortInPlace({$0.sourceRoute?.expectedTravelTime < $1.sourceRoute?.expectedTravelTime})
        guidances.insert(userGuidance, atIndex: 0)
        for index in 0..<guidances.count {
            if index + 1 != guidances.count {
                guard let source = guidances[index].destinationMapItem else {return}
                guard let destination = guidances[index + 1].destinationMapItem else {return}
                searchForFinalRouteBetween(source, destination: destination)
            }
        }
    }
    
    func setUpTurnByTurnUI(){
        hideOverlay(false, viewCollection: [guidanceLabel, guidanceLabelContainer])
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handlerSwipeLeftGesture))
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handlerSwipeRightGesture))
        swipeRightGestureRecognizer.direction = .Right
        swipeLeftGestureRecognizer.direction = .Left
        guidanceLabelContainer.addGestureRecognizer(swipeLeftGestureRecognizer)
        guidanceLabelContainer.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    func handlerSwipeRightGesture(){
        queNextStepInstructionWithPositiveIncrement(false)
    }
    
    func handlerSwipeLeftGesture(){
        queNextStepInstructionWithPositiveIncrement(true)
    }
    
    func queNextStepInstructionWithPositiveIncrement(positiveIncrement:Bool){
        var i = 0
        positiveIncrement == true ? (i = 1) : (i = -1)
        guard let routeIndex = routeIndexInstructionIndexTuple?.0 else {return}
        guard let stepIndex = routeIndexInstructionIndexTuple?.1 else {return}
        
        if stepIndex + i < finalRoutes[routeIndex].steps.count && stepIndex + i >= 0 {
            routeIndexInstructionIndexTuple = (routeIndex,stepIndex + i)
            guidanceLabel.text = finalRoutes[routeIndex].steps[stepIndex + i].instructions
        }
        else if routeIndex + i < finalRoutes.count && routeIndex + i >= 0 {
            routeIndexInstructionIndexTuple = (routeIndex + i, 0)
            guidanceLabel.text = finalRoutes[routeIndex + i].steps[stepIndex].instructions
        }
    }
    
    func searchForFinalRouteBetween(source:MKMapItem, destination:MKMapItem){
        guard let request = initializeRequest(source, destination: destination) else {return}
        let directions = MKDirections(request: request)
        searchForFastestRouteWithDirections(directions, withCompletionHandler: { (route) in
            guard let fastestRoute = route else {return}
            self.plotPolylineWithRoute(fastestRoute, mapView: self.taskMapView)
            self.finalRoutes += [fastestRoute]
            self.guidanceLabel.text = self.finalRoutes.first?.steps.first?.instructions
            self.routeIndexInstructionIndexTuple = (0,0)
            self.showETALabelWithRoutes(self.finalRoutes)
        })
    }

    @IBAction func cancelGuidance(sender: UIButton) {
        setUpGuidanceUI(false)
        routeIndexInstructionIndexTuple = nil
        finalRoutes.removeAll()
        hideGuidance()
        guidanceEnabled = true
        for overlay in taskMapView.overlays {
        taskMapView.removeOverlay(overlay)
        }
        for annotation in taskMapView.annotations {
        taskMapView.removeAnnotation(annotation)
        }
        for tgr in taskMapView.gestureRecognizers! {
        taskMapView.removeGestureRecognizer(tgr)
        }
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func hideGuidance(){
        if guidanceLabelContainer.hidden == false {
            hideOverlay(true, viewCollection: [guidanceLabelContainer, guidanceLabel, guidanceContainer, cancelButton, etaLabel])
        }
        else {
            hideOverlay(false, viewCollection: [guidanceLabelContainer, guidanceLabel, guidanceContainer, cancelButton, etaLabel])
        }
    }

}