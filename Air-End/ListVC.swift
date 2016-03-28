//
//  ListVC.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import MapKit

class ListVC: UIViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var tasks : Results<Task>?
    let taskManager = Task()
    var closeMapItems = [String:[MKMapItem]]()
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var selectedTask:Task?
    var selectedClosestTask:MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getLocation()
    }
    
    func getLocation(){
        locationManager.delegate = self
        determineLocationAuthorizationStatus()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentDueSoon()
    }
    
    func setUpUI(){
        let add = UIBarButtonItem(barButtonSystemItem:.Add, target: self, action: "addItemButtonWasTapped")
        navigationItem.rightBarButtonItem = add
        navigationItem.title = "Lists"
    }
    
    //MARK: - Segmented Control
    
    func segmentDueSoon(){
        taskManager.readTasksDueSoon { (tasks) -> () in
            self.tasks = tasks
            self.tableView.reloadData()
        }
    }
    
    func segmentCloseTasks(){
        taskManager.readAllTasks { (tasks) -> () in
            self.tasks = tasks
            for task in tasks {
                if let descriptor = task.hashtag?.descriptor {
                    self.findCloseLocationsMatchingNoun(descriptor)
                }
            }
        }
    }
    
    func segmentFullList(){
        taskManager.readAllTasks(withCompletionHandler: { (tasks) -> () in
            self.tasks = tasks
            self.tableView.reloadData()
        })
    }
    
    
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            segmentDueSoon()
        case 1:
            if determineLocationAuthorizationStatus() == true {
                segmentCloseTasks()
            }
            else {
                //display warning
            }
        case 2:
            segmentFullList()
        default:
            assertionFailure("received extroneous input from segmented control")
        }
    }
    
    func addItemButtonWasTapped(){
        performSegueWithSegueIdentifier(SegueIdentifier.SegueToNewTaskVC, sender: self)
    }
    
    @IBAction func unwindToListVC(segue:UIStoryboardSegue){}
    
    
    //MARK: - Segue Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let taskMapVC = segue.destinationViewController as? TaskMapVC {
            taskMapVC.closestTask = selectedClosestTask
            taskMapVC.task = selectedTask
        }
    }
}

//MARK: - TableView Delegate Methods

extension ListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithCellIdentifier(UITableView.CellIdentifier.ListCell)
        guard let task = tasks?[indexPath.row] else { return cell}
        if segmentedControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = task.name
            cell.detailTextLabel?.text = findClosestLocationNameForTask(task)
        }
        else {
            cell.textLabel?.text = task.name
            cell.detailTextLabel?.text = convertNSDateToString(task.dueDate)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let task = tasks?[indexPath.row] {
            guard let descriptor = task.hashtag?.descriptor else {return}
            let closestTask = closeMapItems[descriptor]?.first
            if closestTask != nil {
                selectedTask = task
                selectedClosestTask = closestTask
                performSegueWithSegueIdentifier(SegueIdentifier.SegueToMapTaskVC, sender: self)
            }
        }
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfTasks = tasks?.count else { return 0}
        return numberOfTasks
    }
}

