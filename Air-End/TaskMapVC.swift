//
//  TaskMapVC.swift
//  Air-End
//
//  Created by Aaron B on 3/23/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

class TaskMapVC: UIViewController {
    @IBOutlet var taskLabel: UILabel!
    @IBOutlet var taskMapView: MKMapView!
    var task:Task?
    var closestTask:MKMapItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        dropPinsForTask()
    }
    
    func setUpUI(){
        taskLabel.text = task?.name
        taskMapView.showsUserLocation = true
    }
    //make generic
    func dropPinsForTask() {
        var annotations = [MKPointAnnotation]()
        let closestTaskAnnotation = calculateCloseTaskAnnotation()
        annotations.append(closestTaskAnnotation)
        taskMapView.showAnnotations(annotations, animated: true)
    }
    
    //make generic and put in extension
    func calculateCloseTaskAnnotation() -> MKPointAnnotation {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.title = closestTask?.name
        newAnnotation.coordinate = (closestTask?.placemark.location?.coordinate)!
        return newAnnotation
    }
}
