//
//  GTFSStop.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSStop: GTFSBaseModel {
    
    dynamic var stop_id : Int = -1
    dynamic var stop_code : String? = nil
    dynamic var stop_name : String = ""
    dynamic var stop_desc : String? = nil
    dynamic var stop_lat : Double = 0.0
    dynamic var stop_lon : Double = 0.0
    dynamic var zone_id : String? = nil
    dynamic var stop_url : String? = nil
    let location_type = RealmOptional<Int>()
    let parent_station = RealmOptional<Int>()
    dynamic var stop_timezone : String? = nil
    let wheelchair_boarding = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "stop_id"
    }
    
    override class func typecast() -> ((String, AnyObject) -> AnyObject) {
        return { (key,value) in
            
//            switch key {
//            case "stop_id":
//                if value is NSNumber {
//                    return value.intValue!
//                }else{ return value }
//            default:
                return value
//            }
            
        }
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
