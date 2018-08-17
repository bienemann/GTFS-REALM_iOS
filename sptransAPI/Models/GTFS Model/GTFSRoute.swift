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
    
    @objc dynamic var route_id : String = ""
    @objc dynamic var agency_id : String? = nil
    @objc dynamic var route_short_name : String = ""
    @objc dynamic var route_long_name : String = ""
    @objc dynamic var route_desc : String? = nil
    @objc dynamic var route_type : Int = 999
    @objc dynamic var route_url : String? = nil
    @objc dynamic var route_color : String? = nil
    @objc dynamic var route_text_color : String? = nil
    
    override static func primaryKey() -> String? {
        return "route_id"
    }
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "route_type":
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
