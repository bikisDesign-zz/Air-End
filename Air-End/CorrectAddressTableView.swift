//
//  CorrectAddressTableView.swift
//  Air-End
//
//  Created by Aaron B on 4/2/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit
protocol CorrectAddressTableViewDelegate: class {
    func didSetValidAddress(sender:CorrectAddressTableView)
}

class CorrectAddressTableView: UITableView {
    weak var correctAddressTableViewDelegate:CorrectAddressTableViewDelegate?
    var mainViewController:UIViewController?
    var addresses: [String]!
    var placemarkArray: [CLPlacemark]!
    var currentTextField: UITextField!
    var sender: UIButton!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
        backgroundColor = Theme.Colors.LabelColor.color
        separatorColor = Theme.Colors.RedBackgroundColor.color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CorrectAddressTableView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = Theme.Fonts.BoldTitleTypeFace.font
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .Center
        label.text = "Please Select a Specific Address"
        label.backgroundColor = Theme.Colors.BackgroundColor.color
        return label
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if addresses.count > indexPath.row {
            currentTextField.text = addresses[indexPath.row]
            if let mapVC = mainViewController as! MapVC? {
                correctAddressTableViewDelegate?.didSetValidAddress(self)
                mapVC.destinationTextField.text = currentTextField.text
            }
            sender.selected = true
        }
        removeFromSuperview()
    }
}

extension CorrectAddressTableView: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as UITableViewCell!
        cell.textLabel?.numberOfLines = 5
        if addresses.count > indexPath.row {
            cell.textLabel?.text = addresses[indexPath.row]
            cell.detailTextLabel?.text = placemarkArray[indexPath.row].name
           
        } else {
            cell.textLabel?.text = "Nope! Lemme try that again"
        }
        cell.detailTextLabel?.font = Theme.Fonts.TitleTypeFace.font
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = Theme.Fonts.TitleTypeFace.font
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = Theme.Colors.LabelColor.color
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}