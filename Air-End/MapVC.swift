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
    var closeMapItems = [String:MKMapItem]()
    var routeIndexInstructionIndexTuple:(Int,Int)?
    var guidanceRoutes:[MKRoute]?
    
    @IBOutlet var addDestinationButton: UIButton!
    @IBOutlet var checkDestinationButton: UIButton!
    @IBOutlet var enRouteOutletCollection: [UIView]!
    @IBOutlet var enRouteView: UIView!
    
    @IBOutlet var destinationTextField: UITextField!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var taskMapView: MKMapView!
    @IBOutlet var guidanceButton: UIButton!
    @IBOutlet var guidanceLabel: UILabel!
    @IBOutlet var guidanceLabelContainer: UIView!
    @IBOutlet var guidanceNextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpMapUI()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControlValueChanged(segmentedControl)
    }
    
    func setUpMapUI(){
        enRouteView.backgroundColor = Theme.Colors.BackgroundColor.color
        destinationTextField.backgroundColor = Theme.Colors.LabelColor.color
        guidanceLabelContainer.backgroundColor = Theme.Colors.LabelColor.color
        guidanceLabelContainer.layer.cornerRadius = 10
        guidanceLabelContainer.alpha = 0.7
        guidanceLabel.textColor = UIColor.whiteColor()
        taskMapView.showsUserLocation = true
        taskMapView.delegate = self
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField, destinationTextField, guidanceButton, guidanceLabelContainer, guidanceLabel])
    }
    
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
    
    func getLocation(){
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        if let currentLocation = locations.first {
            self.taskManager.readAllTasks(withCompletionHandler: { (tasks) in
                self.tasks = tasks
                for task in self.tasks! {
                    self.findClosestMapItemMatchingTask(task, userLocation: currentLocation)
                }
            })
        }
        CLGeocoder().reverseGeocodeLocation(locations.last!,
                                            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                                                if let placemarks = placemarks {
                                                    let userPlaceMark = MKPlacemark(placemark: placemarks[0])
                                                    self.userLocation = MKMapItem(placemark: userPlaceMark)
                                                }
        })
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
                self.setMapRegionForMapItems(self.closeMapItems[task.name], mapViewA: self.taskMapView)
                try! uiRealm.write({
                    task.distanceFromUser = distanceFromUser
                })
            }
        })
    }

    
    
    //MARK - Destination Button

    @IBAction func addDestination(sender: UIButton) {
        view.endEditing(true)
        if allTextFieldsAreFilled([destinationTextField]) == true {
            guard let destination = destinationTextField.text else {return}
            searchForMapItemsMatchingNoun(destination, withCompletionHandler: { (mapItems) -> () in
                
                guard let destinationMapItem = mapItems.first else {return}
                guard let currentUserLocation = self.userLocation else {return self.showAlert("We couldn't locate you. Please try again!")}
                self.taskLocations?.append(destinationMapItem)
                self.taskMapView.addAnnotation(self.convertToAnnotationFromMapItem(destinationMapItem))
                self.taskLocations?.insert(currentUserLocation, atIndex: 0)
                var someTime:Double = Double()
                var someRoute:[MKRoute] = [MKRoute]()
                self.calculateCloseTasksEnRouteToDestination(0, time:&someTime, routes:&someRoute)
                self.hideOverlay(true, viewCollection: [self.enRouteView, self.destinationTextField])
            })
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
    
    //MARK - Route Methods

    
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
                self.guidanceRoutes = routes
                self.showRoute(routes)
            }
        }
    }
    
    
    func showRoute(routes: [MKRoute]) {
        for i in (0..<routes.count).reverse() {
            plotPolyline(routes[i], index: i)
        }
    }
    
    func setUpGuidanceUI(){
        hideOverlay(false, viewCollection: [guidanceButton])
        segmentedControl.hidden = true
        let tgr = UITapGestureRecognizer(target: self, action: #selector(hideGuidance))
        taskMapView.addGestureRecognizer(tgr)
    }
    
    func hideGuidance(){
        if guidanceLabelContainer.hidden == false {
            hideOverlay(true, viewCollection: [guidanceLabelContainer, guidanceNextButton, guidanceLabel])
        }
        else {
            hideOverlay(false, viewCollection: [guidanceLabelContainer, guidanceNextButton, guidanceLabel])
        }
    }

    func plotPolyline(route: MKRoute, index: Int) {
        setUpGuidanceUI()
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            polylineRenderer.strokeColor = Theme.randomColor().color
            polylineRenderer.lineWidth = 5
        }
        return polylineRenderer
    }
    
   
}