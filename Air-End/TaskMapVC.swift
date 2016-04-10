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
    @IBOutlet var taskMapView: MKMapView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var nounTextField: UITextField!
    var task:Task?
    var closestTask:MKMapItem?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        setUpUI()
    }
    
    func setUpUI(){
        let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action:#selector(editTask))
        navigationItem.rightBarButtonItem = editButton
        hideOverlay(true, viewCollection: [overlayView, taskTextField, nounTextField])
        taskMapView.showsUserLocation = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tgr)
    }
    
    func endEditing(){
        view.endEditing(true)
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
                    else {
                        print("didn't find any close tasks")
                    }})}
            else{
                print("request returned nil")}
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
        setRegionForUnionOfUserLocationAndTaskAnnotation(taskAnnotation, userLocation: locations.first!, mapView: taskMapView)
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
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if mapView.annotations.last! is MKUserLocation {
            return
        }
        else {
            mapView.selectAnnotation(mapView.annotations.last!, animated: true)
        }
    }
}
