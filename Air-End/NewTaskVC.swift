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
        textFields = [taskTextField, nounTextField]
        containers = [taskContainer, nounContainer, dateContainer]
        let tapGR = UITapGestureRecognizer(target: self, action: "handleSingleTap")
        view.addGestureRecognizer(tapGR)
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    func handleSingleTap(){
        view.endEditing(true)
    }
    @IBAction func datePickerChanged(sender: UIDatePicker) {date = datePicker.date
        
    }
    
    @IBAction func sendButtonWasTapped(sender: UIButton) {
        if allTextFieldsAreFilled(textFields) {
            
            let id = generateRandomPassCode()
            let noun = Noun()
            noun.descriptor = textFields[1].text!
            
            task.createNewTaskWith(id, name: textFields[0].text!, dueDate: date, noun:noun, withCompletionHandler: { (newTask) -> () in
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
