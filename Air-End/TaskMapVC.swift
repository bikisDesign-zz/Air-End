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
    }
    
    func setUpUI(){
        taskLabel.text = task?.name
        taskMapView.showsUserLocation = true
        let taskAsAnnotation = convertToAnnotationFromMapItem(closestTask!)
        var annotations = [MKPointAnnotation]()
        annotations.append(taskAsAnnotation)
        taskMapView.showAnnotations(annotations, animated: true)
    }
    
    
}