//
//  MapVC.swift
//  Air-End
//
//  Created by Aaron B on 3/27/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import CoreLocation


class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var tasks : Results<Task>?
    let taskManager = Task()
    var locationManager = CLLocationManager()
    var taskLocations:[MKMapItem]?
    var userLocation:MKMapItem?
    var addressValidated:Bool?
    
    @IBOutlet var addDestinationButton: UIButton!
    @IBOutlet var checkDestinationButton: UIButton!
    @IBOutlet var enRouteOutletCollection: [UIView]!
    @IBOutlet var enRouteView: UIView!
    
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var taskMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapUI()
    }
    
    func setUpMapUI(){
        enRouteView.backgroundColor = Theme.Colors.BackgroundColor.color
        destinationTextField.backgroundColor = Theme.Colors.LabelColor.color
        taskMapView.showsUserLocation = true
        locationManager.delegate = self
        taskMapView.delegate = self
        locationManager.startUpdatingLocation()
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField])
    }
    
    //    func enRouteUI(isHidden:Bool){
    //        UIView.animateWithDuration(1.0) {
    //            self.enRouteView.hidden = isHidden
    //            self.enRouteView.alpha = 1.0
    //            self.destinationTextField.hidden = isHidden
    //        }
    //    }
    
    func checkDestinationUI(isHidden:Bool){
        UIView.animateWithDuration(1.0) {
            if isHidden == true {
                self.checkDestinationButton.hidden = true
                self.checkDestinationButton.alpha = 0.0
                self.addDestinationButton.hidden = false
                self.addDestinationButton.alpha = 1.0
            }
            else {
                self.checkDestinationButton.hidden = false
                self.checkDestinationButton.alpha = 1.0
                self.addDestinationButton.hidden = true
                self.addDestinationButton.alpha = 0.0
            }
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!,
                                            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                                                if let placemarks = placemarks {
                                                    let userPlaceMark = MKPlacemark(placemark: placemarks[0])
                                                    self.userLocation = MKMapItem(placemark: userPlaceMark)
                                                }
        })
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        segmentedControlValueChanged(segmentedControl)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            if mapView.overlays.count == 1 {
                polylineRenderer.strokeColor =
                    UIColor.blueColor().colorWithAlphaComponent(0.75)
            } else if mapView.overlays.count == 2 {
                polylineRenderer.strokeColor =
                    UIColor.greenColor().colorWithAlphaComponent(0.75)
            } else if mapView.overlays.count == 3 {
                polylineRenderer.strokeColor =
                    UIColor.redColor().colorWithAlphaComponent(0.75)
            }
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }
    
    
    @IBAction func addDestination(sender: UIButton) {
        view.endEditing(true)
        if allTextFieldsAreFilled([destinationTextField]) == true {
            guard let destination = destinationTextField.text else {return}
            searchForMapItemsMatchingNoun(destination, withCompletionHandler: { (mapItems) -> () in
                
                guard let destinationMapItem = mapItems.first else {return}
                guard let currentUserLocation = self.userLocation else {return self.showAlert("We couldn't locate you. Please try again!")}
                self.taskLocations?.append(destinationMapItem)
                self.taskLocations?.insert(currentUserLocation, atIndex: 0)
                var someTime:Double = Double()
                var someRoute:[MKRoute] = [MKRoute]()
                self.calculateCloseTasksEnRouteToDestination(0, time:&someTime, routes:&someRoute)
                self.hideOverlay(true, viewCollection: [self.enRouteView, self.destinationTextField])
            })
        }
    }
    
    func calculateCloseTasksEnRouteToDestination(index:Int, inout time:NSTimeInterval, inout routes:[MKRoute]){
        let request:MKDirectionsRequest = MKDirectionsRequest()
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        request.source = taskLocations?[index]
        request.destination = taskLocations?[index + 1]
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler {(
            response: MKDirectionsResponse?,
            error: NSError?) in
            guard let routeResponse = response?.routes else {return self.showAlert("could not find directions for \(self.taskLocations?[index].name)")}
            let fastestRoute:MKRoute = routeResponse.sort({$0.expectedTravelTime < $1.expectedTravelTime})[0]
            routes.append(fastestRoute)
            time += fastestRoute.expectedTravelTime
            if index + 2 < self.taskLocations?.count {
                self.calculateCloseTasksEnRouteToDestination(index + 1, time: &time, routes: &routes)
            }
            else {
                self.showRoute(routes)
            }
        }
    }
    
    @IBAction func checkDestination(sender: UIButton) {
        if allTextFieldsAreFilled([destinationTextField]) == true {
            view.endEditing(true)
            let correctAddressTableView = CorrectAddressTableView()
            correctAddressTableView.correctAddressTableViewDelegate = self
            searchForValidAddress(sender, destinationTextField: destinationTextField, viewController: self)
        }
    }
    
    
    
    func plotPolyline(route: MKRoute) {
        taskMapView.addOverlay(route.polyline)
        if taskMapView.overlays.count == 1 {
            taskMapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                          edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                          animated: false)
        }
        else {
            let polylineBoundingRect =  MKMapRectUnion(taskMapView.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            taskMapView.setVisibleMapRect(polylineBoundingRect,
                                          edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                          animated: false)
        }
    }
    
    func showRoute(routes: [MKRoute]) {
        for i in 0..<routes.count {
            plotPolyline(routes[i])
        }
    }
}