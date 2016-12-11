//
//  MeterValue.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 10.12.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import RealmSwift

class MeterValue: Object {
    dynamic var value: Double = 0.0
    dynamic var createdAt = NSDate()
}
