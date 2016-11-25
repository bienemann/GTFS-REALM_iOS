//
//  GTFSShape.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSShape: GTFSBaseModel {
    
    dynamic var shape_id : Int = 0
    dynamic var shape_pt_lat : Double = 0.0
    dynamic var shape_pt_lon : Double = 0.0
    dynamic var shape_pt_sequence : Int = -1
    let shape_dist_traveled = RealmOptional<Double>()
    
    override class func typecast() -> ((String, AnyObject) -> AnyObject) {
        return { (key,value) in
            
//            switch key {
//            case "shape_id": fallthrough
//            case "shape_pt_sequence":
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
