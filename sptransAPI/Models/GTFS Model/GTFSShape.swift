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
    
    @objc dynamic var shape_id : Int = 0
    @objc dynamic var shape_pt_lat : Double = 0.0
    @objc dynamic var shape_pt_lon : Double = 0.0
    @objc dynamic var shape_pt_sequence : Int = -1
    let shape_dist_traveled = RealmOptional<Double>()
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "shape_id": fallthrough
            case "shape_pt_sequence":
                return Int(value as! String)
            case "shape_dist_traveled": fallthrough
            case "shape_pt_lat": fallthrough
            case "shape_pt_lon":
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
