//
//  NewTaskVC.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit

class NewTaskVC: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var sendButtonContainer: UIView!
    @IBOutlet var dateContainer: UIView!
    @IBOutlet var nounContainer: UIView!
    @IBOutlet var taskContainer: UIView!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var nounTextField: UITextField!
    @IBOutlet var taskTextField: UITextField!
    var date = NSDate()
    var textFields = [UITextField]()
    var containers = [UIView]()
    var task = Task()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI(){
        navigationItem.backBarButtonItem?.tintColor = Theme.Colors.ButtonColor.color
        view.backgroundColor = Theme.Colors.BackgroundColor.color
        textFields = [taskTextField, nounTextField]
        containers = [taskContainer, nounContainer]
       
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        view.addGestureRecognizer(tapGR)
        for container in containers {
            container.layer.cornerRadius = 10
            container.backgroundColor = Theme.Colors.LabelColor.color
        }
        for textField in textFields {
            textField.delegate = self
            textField.backgroundColor = Theme.Colors.LabelColor.color
            textField.textColor = UIColor.whiteColor()
            textField.layer.cornerRadius = 10
        }
        
        sendButton.backgroundColor = Theme.Colors.ButtonColor.color
        
        sendButtonContainer.layer.cornerRadius = sendButtonContainer.bounds.size.width / 2.0
        sendButtonContainer.backgroundColor = sendButton.backgroundColor
        sendButton.layer.cornerRadius = sendButton.bounds.size.width / 2.0
        
        datePicker.backgroundColor = UIColor.clearColor()
        dateContainer.backgroundColor = datePicker.backgroundColor
    }
    
    func handleSingleTap(){
        view.endEditing(true)
    }
    @IBAction func datePickerChanged(sender: UIDatePicker) {date = datePicker.date
        
    }
    
    @IBAction func createNewTask(sender: UIButton) {
        if allTextFieldsAreFilled(textFields) {
            
            let id = generateRandomPassCode()
            let noun = Noun()
            noun.descriptor = textFields[1].text!
            
            task.createNewTaskWithID(id, name: taskTextField.text!, dueDate: datePicker.date, noun:noun, withCompletionHandler: { (newTask) in
            self.performSegueWithSegueIdentifier(SegueIdentifier.SegueUnwindToListVC, sender: self)
            })
        }
    }
}

extension NewTaskVC: UITextFieldDelegate {
    
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //        <#code#>
    //    }
    //
    //    func textFieldDidEndEditing(textField: UITextField) {
    //        <#code#>
    //    }
}
