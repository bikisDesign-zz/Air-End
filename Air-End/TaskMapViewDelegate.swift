//
//  TaskMapViewDelegateViewController.swift
//  Air-End
//
//  Created by Aaron B on 4/15/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

extension MapVC {
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let annotation = view.annotation else {return}
        for i in 0..<guidances.count {
            guard let location = guidances[i].destinationMapItem else {return}
            if matchCoordinatesOfMapItemAndAnnoatation(annotation, mapItem: location) == true {
                displaySelectedGuidanceRoute(i)
                
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        let reuseID = "annotation ID"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView.canShowCallout = true
        if let location = destinationMapItem {
            if matchCoordinatesOfMapItemAndAnnoatation(annotation, mapItem: location) == true {
                pinView.animatesDrop = true
                pinView.pinTintColor = Theme.Colors.RedColor.color
                anView = pinView
                return anView
            }
        }
        if userSelectingAdditionalRoutes == true {
            let addRouteButton = UIButton(type: .ContactAdd)
            addRouteButton.frame = CGRectMake(0, 0, 25, 25)
            pinView.rightCalloutAccessoryView = addRouteButton
        }
        if guidanceEnabled == true {
            let rightButton = UIButton(type: .Custom)
            rightButton.setImage(UIImage(named: "Route-Small"), forState: .Normal)
            rightButton.frame = CGRectMake(0, 0, 25, 25)
            pinView.rightCalloutAccessoryView = rightButton
        }
        pinView.pinTintColor = Theme.Colors.YellowColor.color
        anView = pinView
        return anView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.rightCalloutAccessoryView = nil
        if userSelectingAdditionalRoutes == false {
            setUpGuidanceUI(true)
            let annotations = mapView.annotations
            for annotation in annotations {
                if annotation !== view.annotation {
                    mapView.removeAnnotation(annotation)
                }
            }
            guard let source = userLocation else {return}
            guard let annotation = view.annotation else {return}
            guard let noun = annotation.title else {return}
            searchForMapItemsMatchingNoun(noun, userLocation: source) { (mapItems) in
                guard let destination = mapItems?.first else {return}
                guard let request = self.initializeRequest(source, destination: destination) else {return}
                let directions = MKDirections(request: request)
                self.searchForFastestRouteWithDirections(directions, withCompletionHandler: { (route) in
                    guard let fastestRoute = route else {return}
                    self.plotPolylineWithRoute(fastestRoute, mapView: self.taskMapView)
                    self.finalRoutes.removeAll()
                    self.finalRoutes.append(fastestRoute)
                    self.setUpTurnByTurnUI()
                    self.showETALabelWithRoutes([fastestRoute])
                    self.routeIndexInstructionIndexTuple = (0,0)
                })
            }
        }
        else {
            AddRouteToGuidance()
        }
    }
    
    func showETALabelWithRoutes(routes:[MKRoute]) {
        self.hideOverlay(false, viewCollection: [self.guidanceContainer, self.cancelButton, self.etaLabel])
        self.guidanceLabel.text = self.finalRoutes.first?.steps.first?.instructions
        var eta = Double()
        for route in routes {
            eta += route.expectedTravelTime
        }
        self.etaLabel.text = "\(Int(eta / 60)) Mins"
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            let color = generatePolylineColor()
            polylineRenderer.strokeColor = color
            polylineRenderer.lineWidth = 10
            polylineRenderer.alpha = 0.5
        }
        return polylineRenderer
    }
    
    func generatePolylineColor () -> UIColor {
        var color = Theme.randomColor().color
        if color == Theme.Colors.NavigationBarFontColor.color {
            color = generatePolylineColor()
        }
        return color
    }
    
    func displaySelectedGuidanceRoute(i: Int){
        guard let sourceRoute = guidances[i].sourceRoute else {return}
        guard let destinationRoute = guidances[i].destinationRoute else {return}
        guard let finalDestinationRoute = guidances.last?.sourceRoute else {return}
        if i + 1 != guidances.count {
            if guidances[i].wasSelectedForFinalRoute == false {
                routeCounter += [i]
                let differenceToDestination = (sourceRoute.expectedTravelTime + destinationRoute.expectedTravelTime) - (finalDestinationRoute.expectedTravelTime)
                hideOverlay(false, viewCollection: [guidanceLabel, guidanceLabelContainer])
                guidanceLabel.text = "This will add \(Int(differenceToDestination / 60)) more Mins to your ETA"
            }
        }
        else {
            hideOverlay(false, viewCollection: [guidanceLabel, guidanceLabelContainer])
            guidanceLabel.text = "The ETA to your destination is \(Int(sourceRoute.expectedTravelTime / 60)) Mins"
        }
    }
    
    func AddRouteToGuidance() {
        guard let i = routeCounter.last else {return}
        if guidances[i].wasSelectedForFinalRoute == false {
            guidances[i].wasSelectedForFinalRoute = true
        }
        hideOverlay(true, viewCollection: [guidanceLabelContainer, guidanceLabel])
    }
}