//
//  GTFSRoute.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSRoute: Object {
    
    dynamic var route_id : String = ""
    dynamic var agency_id : GTFSAgency?
    dynamic var route_short_name : String = ""
    dynamic var route_long_name : String = ""
    let route_desc : String? = nil
    dynamic var route_type : Int = 999
    let route_url : String? = nil
    let route_color : String? = nil
    let route_text_color : String? = nil
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
