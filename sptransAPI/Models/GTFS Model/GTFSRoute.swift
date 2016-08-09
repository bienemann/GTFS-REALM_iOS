//
//  GTFSRoute.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSRoute: GTFSBaseModel {
    
    dynamic var route_id : String = ""
    dynamic var agency_id : String? = nil
    dynamic var route_short_name : String = ""
    dynamic var route_long_name : String = ""
    dynamic var route_desc : String? = nil
    dynamic var route_type : Int = 999
    dynamic var route_url : String? = nil
    dynamic var route_color : String? = nil
    dynamic var route_text_color : String? = nil
    
    override static func primaryKey() -> String? {
        return "route_id"
    }
    
    override class func typecast() -> ((String, AnyObject) -> AnyObject) {
        return { (key,value) in
            
            switch key {
            case "route_type":
                if value is NSNumber {
                    return value.integerValue!
                }else{ return value }
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
