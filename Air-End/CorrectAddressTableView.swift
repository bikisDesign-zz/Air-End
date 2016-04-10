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
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
        
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
        label.font = Theme.Fonts.BoldNavigationBarTypeFace.font
        label.textAlignment = .Center
        label.text = "Did you mean..."
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
            else {
                //is another VC
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
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = Theme.Fonts.NormalTextTypeFaceLato.font
        
        if addresses.count > indexPath.row {
            cell.textLabel?.text = addresses[indexPath.row]
        } else {
            cell.textLabel?.text = "Nope! Lemme try that again"
        }
        return cell
    }
}