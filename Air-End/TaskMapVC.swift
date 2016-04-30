//
//  TaskMapVC.swift
//  Air-End
//
//  Created by Aaron B on 3/23/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TaskMapVC: UIViewController {
    @IBOutlet var guidanceContainer: UIView!
    @IBOutlet var etaLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var taskMapView: TaskMapView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var nounTextField: UITextField!
    var task:Task?
    var closestTask:MKMapItem?
    let locationManager = CLLocationManager()
    var userLocation:MKMapItem?
    var guidanceEnabled:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        setUpUI()
    }
    
    func setUpUI(){
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action:#selector(editTask))
        navigationItem.rightBarButtonItem = editButton
        cancelButton.setImage(UIImage(named: "Cancel-76"), forState: .Normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        cancelButton.tintColor = UIColor.whiteColor()
        guidanceContainer.backgroundColor = Theme.Colors.OrangeColor.color
        guidanceContainer.alpha = 0.8
        guidanceContainer.layer.cornerRadius = 10
        hideOverlay(true, viewCollection: [overlayView, taskTextField, nounTextField, guidanceContainer, cancelButton, etaLabel])
        taskMapView.showsUserLocation = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tgr)
        guidanceEnabled = false
    }
    
    func endEditing(){
        view.endEditing(true)
    }
    
    func hideGuidance(){
        hideOverlay(!guidanceContainer.hidden, viewCollection: [guidanceContainer, cancelButton, etaLabel])
    }
    
    func setUpGuidanceUI(enabled:Bool){
            tabBarController?.tabBar.hidden = enabled
            navigationController?.setNavigationBarHidden(enabled, animated: true)
            guidanceEnabled = enabled
        if enabled == true {
            let mapSingleTGR = UITapGestureRecognizer(target: self, action: #selector(hideGuidance))
            taskMapView.addGestureRecognizer(mapSingleTGR)
        }
        else {
            guard let tgrs = taskMapView.gestureRecognizers else {return}
            for tgr in tgrs {
            taskMapView.removeGestureRecognizer(tgr)
            }
        }
    }
    
    func searchForClosestAnnotationMatchingNoun(nounDescriptor:String) {
        if let userLocation = taskMapView.userLocation.location {
            if let request = initalizeRequestWithDescriptor(nounDescriptor, location: taskMapView.userLocation.location){
                let search = MKLocalSearch(request: request)
                search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
                    if let mapItems = response?.mapItems {
                        if let sortedMapItems = self.sortMapItemsCloseToUserLocation(userLocation, mapItems: mapItems) {
                            let taskAnnotation = self.convertToAnnotationFromMapItem(sortedMapItems.first!)
                            self.setRegionForUnionOfUserLocationAndTaskAnnotation(taskAnnotation, userLocation: userLocation,mapView:self.taskMapView)
                        }
                    }
                   })}
        }
    }
    
    func editTask(){
        let doneButton = UIBarButtonItem(barButtonSystemItem:.Done, target: self, action: #selector(updateTask))
        navigationItem.rightBarButtonItem = doneButton
        overlayView.backgroundColor = Theme.Colors.BackgroundColor.color
        taskTextField.text = task?.name
        nounTextField.text = task?.hashtag?.descriptor
        hideOverlay(false, viewCollection: [overlayView, taskTextField, nounTextField])
    }
    
    func updateTask(){
        guard let newTask = taskTextField.text else {return}
        if newTask != task?.name && newTask != "" {
            try! uiRealm.write({
                task?.name = newTask
            })
        }
        guard let newNoun = nounTextField.text else {return}
        if newNoun != task?.hashtag?.descriptor && newNoun != "" {
            try! uiRealm.write({
                task?.hashtag?.descriptor = newNoun
                taskMapView.removeAnnotations(taskMapView.annotations)
                searchForClosestAnnotationMatchingNoun(newNoun)
            })
        }
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action:#selector(editTask))
        navigationItem.rightBarButtonItem = editButton
        hideOverlay(true, viewCollection: [overlayView, taskTextField, nounTextField])
    }
}

extension TaskMapVC: CLLocationManagerDelegate{
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let taskAnnotation = convertToAnnotationFromMapItem(closestTask!)
        guard let currentLocation = locations.first else {return}
               setRegionForUnionOfUserLocationAndTaskAnnotation(taskAnnotation, userLocation: currentLocation, mapView: taskMapView)
        CLGeocoder().reverseGeocodeLocation(locations.last!,
                                            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                                                if let placemarks = placemarks {
                                                    let userPlaceMark = MKPlacemark(placemark: placemarks[0])
                                                    self.userLocation = MKMapItem(placemark: userPlaceMark)
                                                }
            })
        locationManager.stopUpdatingLocation()
    }
}

extension TaskMapVC: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = Theme.Colors.ButtonColor.color
            if guidanceEnabled == false {
            let rightButton = UIButton(type: .Custom)
            rightButton.frame = CGRectMake(0, 0, 25, 25)
            rightButton.setImage(UIImage(named: "Route-Small"), forState: .Normal)
            pinView?.rightCalloutAccessoryView = rightButton
            }
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        view.rightCalloutAccessoryView = nil
        setUpGuidanceUI(true)
        guard let source = userLocation else {return}
        guard let destination = closestTask else {return}
        guard let request = initializeRequest(source, destination: destination) else {return}
        let directions = MKDirections(request: request)
        searchForFastestRouteWithDirections(directions) { (route) in
            guard let fastestRoute = route else {return}
            self.plotPolylineWithRoute(fastestRoute, mapView: self.taskMapView)
            self.hideOverlay(false, viewCollection: [self.guidanceContainer, self.cancelButton, self.etaLabel])
            self.etaLabel.text = "\(Int(fastestRoute.expectedTravelTime / 60)) Mins"
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if mapView.annotations.last! is MKUserLocation {
            return
        }
        else {
            mapView.selectAnnotation(mapView.annotations.last!, animated: true)
        }
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
    
    @IBAction func cancelGuidance(sender: UIButton) {
        setUpGuidanceUI(false)
        hideGuidance()
    }
}