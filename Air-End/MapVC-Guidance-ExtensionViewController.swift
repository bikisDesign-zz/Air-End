//
//  MapVC-Guidance-ExtensionViewController.swift
//  Air-End
//
//  Created by Aaron B on 4/11/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
extension MapVC {
    @IBAction func beginGuidance(sender: UIButton) {
        hideOverlay(true, viewCollection: [guidanceButton])
        hideOverlay(false, viewCollection: [guidanceLabel, guidanceLabelContainer, guidanceNextButton])
        if guidanceRoutes?.count > 0 {
            taskMapView.setVisibleMapRect(taskMapView.overlays.last!.boundingMapRect, animated: true)
            guidanceLabel.text = guidanceRoutes?.first?.steps.first?.instructions
            routeIndexInstructionIndexTuple = (1, 1)
        }
    }
    
    @IBAction func cueNextDirection(sender: UIButton) {
        guard let routeIndex = routeIndexInstructionIndexTuple?.0 else {return}
        guard let instructionIndex = routeIndexInstructionIndexTuple?.1 else {return}
        guard let steps = guidanceRoutes?[routeIndex].steps else {return}
        let routeTotal = guidanceRoutes?.count
        let instructionTotal = steps.count
        guidanceLabel.text = steps[instructionIndex].instructions
        if instructionTotal > instructionIndex {
            routeIndexInstructionIndexTuple = (routeIndex, instructionIndex + 1)
        }
        else if routeTotal > routeIndex  {
            routeIndexInstructionIndexTuple = (routeIndex + 1, 1)
        }
        else {
            guidanceNextButton.hidden = true
            guidanceLabel.text = "You've arrived at your destination"
        }
    }
}
