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
    var taskLocations = [MKMapItem]()
    var userLocation:MKMapItem?
    var closeMapItems = [String:MKMapItem]()
    var routeIndexInstructionIndexTuple:(Int,Int)?
    var guidances = [Guidance]()
    var finalRoutes = [MKRoute]()
    var routeCounter = [Int]()
    var destinationMapItem:MKMapItem?
    var guidanceEnabled = Bool()
    var userSelectingAdditionalRoutes = false
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var etaLabel: UILabel!
    @IBOutlet var guidanceContainer: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addDestinationButton: UIButton!
    @IBOutlet var checkDestinationButton: UIButton!
    @IBOutlet var enRouteOutletCollection: [UIView]!
    @IBOutlet var enRouteView: UIView!
    @IBOutlet var destinationTextField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var taskMapView: TaskMapView!
    @IBOutlet var guidanceButton: UIButton!
    @IBOutlet var guidanceLabel: UILabel!
    @IBOutlet var guidanceLabelContainer: UIView!
    
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
        guidanceLabel.adjustsFontSizeToFitWidth = true
        guidanceLabel.textAlignment = .Center
        cancelButton.setImage(UIImage(named: "Cancel-76"), forState: .Normal)
        cancelButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        cancelButton.tintColor = UIColor.whiteColor()
        guidanceContainer.backgroundColor = Theme.Colors.OrangeColor.color
        guidanceContainer.alpha = 0.8
        guidanceContainer.layer.cornerRadius = 10
        taskMapView.showsUserLocation = true
        taskMapView.delegate = self
        hideOverlay(true, viewCollection: [enRouteView, destinationTextField, destinationTextField, guidanceButton, guidanceLabelContainer, guidanceLabel, activityIndicator, guidanceContainer, cancelButton, etaLabel])
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
    
    func setUpGuidanceUI(enabled:Bool){
        tabBarController?.tabBar.hidden = enabled
        navigationController?.setNavigationBarHidden(enabled, animated: true)
        segmentedControl.hidden = enabled
        if enabled == true {
            let mapSingleTGR = UITapGestureRecognizer(target: self, action: #selector(hideGuidance))
            taskMapView.addGestureRecognizer(mapSingleTGR)
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
        hideOverlay(false, viewCollection: [activityIndicator])
        self.activityIndicator.startAnimating()
        if allTextFieldsAreFilled([destinationTextField]) == true {
            guard let destination = destinationTextField.text else {return}
            guard let location = userLocation else {return}
            for annotation in taskMapView.annotations {
                taskMapView.removeAnnotation(annotation)
            }
            userSelectingAdditionalRoutes = true
            searchForMapItemsMatchingNoun(destination,
                                          userLocation: location,
                                          withCompletionHandler: {
                                            (result) -> () in
                                            guard let mapItems = result else {return self.showAlert("We couldn't locate a close location matching \(destination)")}
                                            guard let destinationMapItem = mapItems.first else {return}
                                            guard let currentUserLocation = self.userLocation else {
                                                return self.showAlert("We couldn't locate you. Please try again!")}
                                            for task in self.tasks! {
                                                let taskLocation = (self.closeMapItems[task.name]!)
                                                self.taskLocations.append(taskLocation)
                                                self.taskMapView.addAnnotation(self.convertToAnnotationFromMapItem(taskLocation))
                                            }
                                            self.taskLocations.insert(currentUserLocation, atIndex: 0)
                                            self.taskLocations.append(destinationMapItem)
                                            self.hideOverlay(true, viewCollection: [self.enRouteView, self.destinationTextField])
                                            self.destinationMapItem = destinationMapItem
                                            let destinationAnnotation = self.convertToAnnotationFromMapItem(destinationMapItem)
                                            self.taskMapView.addAnnotation(destinationAnnotation)
                                            self.findTasksEnrouteToDestination()
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
    func findTasksEnrouteToDestination(){
        guard let source = taskLocations.first else {return print("source not available")}
        guard let destination = taskLocations.last else {return print ("destination not available")}
        
        guard let sourceToDestinationRequest = initializeRequest(source, destination: destination) else {return}
        
        let sourceToDestinationDirections = MKDirections(request:sourceToDestinationRequest)
        
        searchForFastestRouteWithDirections(sourceToDestinationDirections) { (sourceToDestinationRoute) in
            guard let sToDRoute = sourceToDestinationRoute else {return}
            self.routeAllCloseTasksEnRouteToDestination(source, destination: destination, sourceToDestinationRoute: sToDRoute, index: 1)
        }
    }
    
    func routeAllCloseTasksEnRouteToDestination(source: MKMapItem,
                                                destination:MKMapItem,
                                                sourceToDestinationRoute:MKRoute,
                                                var index: Int){
        
        let sourceToDestinationETA = sourceToDestinationRoute.expectedTravelTime
        guard let sourceToTaskRequest = initializeRequest(source,
                                                          destination: taskLocations[index]) else {return}
        let sourceToTaskDirections = MKDirections(request: sourceToTaskRequest)
        
        searchForFastestRouteWithDirections(sourceToTaskDirections) { (sourceToTaskRoute) in
            guard let sourceToTaskETA = sourceToTaskRoute?.expectedTravelTime else {return}
            if  sourceToTaskETA - 600 < sourceToDestinationETA {
                
                guard let taskToDestinationRequest = self.initializeRequest(self.taskLocations[index], destination: destination) else {return}
                let taskToDestinationDirections = MKDirections(request: taskToDestinationRequest)
                self.searchForFastestRouteWithDirections(taskToDestinationDirections, withCompletionHandler: { (taskToDestinationRoute) in
                    guard let taskToDestinationETA = taskToDestinationRoute?.expectedTravelTime else {return}
                    
                    if sourceToTaskETA + taskToDestinationETA - 600 < sourceToDestinationETA {
                        
                        let newGuidance = Guidance(index: index - 1,
                                                    sourceRoute: sourceToTaskRoute,
                                                    destinationRoute: taskToDestinationRoute,
                                                    destinationMapItem: self.taskLocations[index])
                        
                        self.guidances += [newGuidance]
                    }
                    else{
                        self.taskLocations.removeAtIndex(index)
                        index -= 1
                    }
                    self.determineRemaningDestinationsWithSource(source,
                                                                destination: destination,
                                                                sourceToDestinationRoute:
                                                                sourceToDestinationRoute,
                                                                index: index)
                })
            }
            else {
                self.taskLocations.removeAtIndex(index)
                index -= 1
                self.determineRemaningDestinationsWithSource(source,
                                                             destination: destination,
                                                             sourceToDestinationRoute: sourceToDestinationRoute,
                                                             index: index)
            }
        }
    }
    
    
    func determineRemaningDestinationsWithSource(source: MKMapItem,
                                                 destination:MKMapItem,
                                                 sourceToDestinationRoute:MKRoute,
                                                 var index: Int){
        if index < self.taskLocations.count - 2 {
            routeAllCloseTasksEnRouteToDestination(source,
                                                   destination: destination,
                                                   sourceToDestinationRoute: sourceToDestinationRoute,
                                                   index: index + 1)
        }
        else {
            let newGuidance = Guidance(index: index - 1,
                                       sourceRoute: sourceToDestinationRoute,
                                       destinationRoute: MKRoute(),
                                       destinationMapItem: destination)
            
            newGuidance.wasSelectedForFinalRoute = true
            guidances += [newGuidance]
            segmentedControl.hidden = true
            showRoute()
        }
    }
    
    func showRoute() {
        for guidance in guidances {
            guard let source = guidance.sourceRoute  else {return}
            hideOverlay(false, viewCollection: [guidanceButton])
            plotPolylineWithRoute(source, mapView: taskMapView)
        }
        self.activityIndicator.stopAnimating()
    }
    
    
  }