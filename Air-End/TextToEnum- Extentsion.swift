//
//  TextToEnum- Extentsion.swift
//  Air-End
//
//  Created by Aaron B on 3/21/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import UIKit

extension UIViewController {
    enum SegueIdentifier: String {
        case SegueToNewTaskVC = "SegueToNewTaskVC"
        case SegueUnwindToListVC = "SegueUnwindToListVC"
        case SegueToMapTaskVC = "SegueToTaskMapVC"
    }
    
    func performSegueWithSegueIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
    }
    
    func shouldPerformSegueWithSegueIdentifier(segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        shouldPerformSegueWithIdentifier(segueIdentifier.rawValue, sender: sender)
    }
}

extension UITableView {
    enum CellIdentifier: String {
        case ListCell = "List Cell"
    }
    
    func dequeueReusableCellWithCellIdentifier(cellIdentifier: CellIdentifier) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(cellIdentifier.rawValue)!
    }
}
