//
//  GTFSStopTime.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSStopTime: GTFSBaseModel {
    
    @objc dynamic var trip_id : String = ""
    @objc dynamic var arrival_time : String = ""
    @objc dynamic var departure_time : String = ""
    @objc dynamic var stop_id : Int = -1
    @objc dynamic var stop_sequence : Int = -1
    @objc dynamic var stop_headsign : String? = nil
    let pickup_type = RealmOptional<Int>()
    let drop_off_type = RealmOptional<Int>()
    let shape_dist_traveled = RealmOptional<Double>()
    let timepoint = RealmOptional<Int>()
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "stop_sequence": fallthrough
            case "stop_id": fallthrough
            case "pickup_type": fallthrough
            case "drop_off_type": fallthrough
            case "timepoint":
                return Int(value as! String)
            case "shape_dist_traveled":
                return Double(value as! String)
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
