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
    var closeMapItems = [String:[MKMapItem]]()
    var currentLocation:CLLocation?
    
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
        taskMapView.showsUserLocation = true
        locationManager.delegate = self
        taskMapView.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newUserLocation = locations.first as CLLocation? {
            currentLocation = newUserLocation
            locationManager.stopUpdatingLocation()
            readAllTasks()
        }
    }
    
    func readAllTasks(){
        taskManager.readAllTasks(withCompletionHandler: { (tasks) in
            self.tasks = tasks
            if self.tasks != nil {
                for task in self.tasks! {
                    guard let descriptor = task.hashtag?.descriptor else {return}
                    self.findCloseLocationsMatchingNounWithDescriptor(descriptor)
                }
            }
        })
    }
    
    
    func findCloseLocationsMatchingNounWithDescriptor(nounDescriptor:String) {
        guard let userLocation = currentLocation else {return print("could not locate the user")}
        guard let request = initalizeRequestWithDescriptor(nounDescriptor, location: currentLocation) else { return print("could not initilize request")}
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({ (response: MKLocalSearchResponse?, error:NSError?) -> Void in
            guard let mapItems = response?.mapItems else { return print("didn't find any close tasks")}
            let sortedCloseTasks = mapItems.sort({$0.placemark.location?.distanceFromLocation(userLocation) < $1.placemark.location?.distanceFromLocation(userLocation)})
            self.closeMapItems[nounDescriptor] = sortedCloseTasks
            let newAnnotation = self.convertToAnnotationFromMapItem(sortedCloseTasks.first!)
            self.taskMapView.addAnnotation(newAnnotation)
            if let region = self.coordinateRegionForAnnotations(self.taskMapView){
                self.taskMapView.setRegion(region, animated: true)
            }
        })
    }
}
