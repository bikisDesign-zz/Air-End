//
//  Guidance.swift
//  Air-End
//
//  Created by Aaron B on 4/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit
import MapKit

class Guidance: NSObject {
    var sourceRoute : MKRoute?
    var destinationRoute : MKRoute?
    var destinationMapItem : MKMapItem?
    var index : Int?
    var wasSelectedForFinalRoute: Bool?

    init(index: Int?, sourceRoute:MKRoute?, destinationRoute: MKRoute?, destinationMapItem: MKMapItem?) {
        self.index = index
        self.sourceRoute = sourceRoute
        self.destinationRoute = destinationRoute
        self.destinationMapItem = destinationMapItem
        self.wasSelectedForFinalRoute = false
        super.init()
    }
    
}
