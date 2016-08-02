//
//  GTFSStop.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSStop: Object {
    
    dynamic var stop_id : Int = -1
    let stop_code : String? = nil
    dynamic var stop_name : String = ""
    let stop_desc : String? = nil
    dynamic var stop_lat : Double = 0.0
    dynamic var stop_lon : Double = 0.0
    let zone_id : String? = nil
    let stop_url : String? = nil
    let location_type = RealmOptional<Int>()
    let parent_station = RealmOptional<Int>()
    let stop_timezone : String? = nil
    let wheelchair_boarding = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
