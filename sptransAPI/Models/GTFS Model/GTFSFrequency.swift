//
//  GTFSFrequency.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFrequency: GTFSBaseModel {
    
    @objc dynamic var trip_id : String = ""
    @objc dynamic var start_time : String = ""
    @objc dynamic var end_time : String = ""
    @objc dynamic var headway_secs : Int = 0
    let exact_times = RealmOptional<Int>()
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "headway_secs": fallthrough
            case "exact_times":
                return Int(value as! String)
            default:
                return value
            }
            
        }
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
