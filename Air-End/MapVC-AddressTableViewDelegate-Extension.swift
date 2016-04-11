//
//  MapVC-AddressTableViewDelegate-Extension.swift
//  Air-End
//
//  Created by Aaron B on 4/4/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

extension MapVC: CorrectAddressTableViewDelegate {
    
    func searchForValidAddress(sender:UIButton, destinationTextField:UITextField, viewController:UIViewController){
        guard let aDestination = destinationTextField.text else {return}    
        CLGeocoder().geocodeAddressString(aDestination,
                                          completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                                            if let placemarks = placemarks {
                                                var addresses = [String]()
                                                for placemark in placemarks {
                                                    addresses.append(self.convertAddressFromPlacemark(placemark))
                                                }
                                                self.showCorrectAddressTableView(addresses, textField: destinationTextField, placemarks: placemarks, sender: sender, viewController: viewController)
                                            } else {
                                                self.showAlert("Address not found.")
                                            }
        })
    }
    
    func showCorrectAddressTableView(addresses:[String], textField:UITextField, placemarks:[CLPlacemark], sender: UIButton, viewController: UIViewController){
        let addressTableView = CorrectAddressTableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
        addressTableView.correctAddressTableViewDelegate = self
        addressTableView.addresses = addresses
        addressTableView.currentTextField = textField
        addressTableView.placemarkArray = placemarks
        addressTableView.sender = sender
        addressTableView.delegate = addressTableView
        addressTableView.dataSource = addressTableView
        addressTableView.mainViewController = viewController
        view.addSubview(addressTableView)
    }
    
    
    func didSetValidAddress(sender: CorrectAddressTableView) {
            checkDestinationUI(true)
    }
}