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
        var addresses = [String]()
        searchForMapItemsMatchingNoun(destinationTextField.text, userLocation: userLocation) { (result) -> () in
            var placemarks = [CLPlacemark]()
            guard let mapItems = result else {return self.showAlert("Couldn't not find a match to the address")}
            for mapItem in mapItems {
                placemarks.append(mapItem.placemark)
                addresses.append(self.convertAddressFromPlacemark(mapItem.placemark))
            }
             self.showCorrectAddressTableView(addresses, textField: destinationTextField, placemarks: placemarks, sender: sender, viewController: viewController)
        }
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