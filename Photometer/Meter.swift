//
//  Meter.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 11.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Meter: Object {
    dynamic var name = ""
    dynamic var createdAt = NSDate()
    var values: List<MeterValue> = List()
    
    var image: UIImage? {
        get {
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
            let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            if let dirPath        = paths.first
            {
                let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
                return UIImage(contentsOfFile: imageURL.path)
            }
            return nil
        }
        set {
            let writePath = FileManager.documentsDirectory().appendingPathComponent(name)
            if let newImage = newValue, let data = UIImageJPEGRepresentation(newImage, 1.0) {
                try? data.write(to: writePath)
            }
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["image"]
    }
}

extension FileManager {
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
}
