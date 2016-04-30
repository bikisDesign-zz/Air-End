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
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var tasks : Results<Task>?
    let taskManager = Task()
    var closeMapItems = [String:MKMapItem]()
    let locationManager = CLLocationManager()
    var currentLocation:CLLocation?
    var selectedTask:Task?
    var selectedClosestTask:MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControlValueChanged(segmentedControl)
        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    func getLocation(){
        locationManager.delegate = self
        determineLocationAuthorizationStatus()
    }
    
    func setUpUI(){
        let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action:#selector(addItemButtonWasTapped))
        navigationItem.rightBarButtonItem = add
        navigationItem.title = " M A N G O "
        tableView.backgroundColor = Theme.Colors.LabelColor.color
        tableView.separatorColor = Theme.Colors.NavigationBarColor.color
        viewContainer.backgroundColor = tableView.backgroundColor
    }
    
    //MARK: - Segmented Control
    
    func segmentDueSoon(){
        getLocation()
        taskManager.readTasksDueSoon { (tasks) -> () in
            self.tasks = tasks
            self.tableView.reloadData()
        }
    }
    
    func segmentCloseTasks(){
            taskManager.readCloseTasks(withCompletionHandler: { (closeTasks) in
            self.tasks = closeTasks
            self.tableView.reloadData()
        })
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfTasks = tasks?.count else { return 0}
        return numberOfTasks
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithCellIdentifier(UITableView.CellIdentifier.ListCell)
        guard let task = tasks?[indexPath.row] else { return cell}
        if segmentedControl.selectedSegmentIndex == 1 {
            cell.textLabel?.text = task.name
            cell.detailTextLabel?.text = closeMapItems[task.name]?.name
        }
        else {
            cell.textLabel?.text = task.name
            cell.detailTextLabel?.text = convertNSDateToString(task.dueDate)
        }
        cell = setUpTableviewCellUI(cell)
        return cell
    }
    
    func setUpTableviewCellUI(cell:UITableViewCell) -> UITableViewCell{
        cell.selectionStyle = .None
        cell.backgroundColor = Theme.Colors.LabelColor.color
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = Theme.Fonts.TitleTypeFace.font
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.font = Theme.Fonts.TitleTypeFace.font
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let task = tasks?[indexPath.row] else {return}
        if closeMapItems.count > 0 {
        let selectedMapItem = closeMapItems[task.name]
        selectedTask = task
        selectedClosestTask = selectedMapItem
        performSegueWithSegueIdentifier(SegueIdentifier.SegueToMapTaskVC, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            guard let task = tasks?[indexPath.row] else {return}
            taskManager.removeTask(task, withCompletionHandler: { (tasks) in
                self.tasks = tasks
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
}