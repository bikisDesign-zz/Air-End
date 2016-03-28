//
//  Noun.swift
//  Air-End
//
//  Created by Aaron B on 3/22/16.
//  Copyright © 2016 Bikis Design. All rights reserved.
//

import Foundation
import RealmSwift

class Noun: Object {
    dynamic var descriptor:String?
    dynamic var parentTask:Task?
}
