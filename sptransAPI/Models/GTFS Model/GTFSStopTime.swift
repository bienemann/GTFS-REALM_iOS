//
//  GTFSStopTime.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSStopTime: Object {
    
    dynamic var trip_id : String = ""
    dynamic var arrival_time : String = ""
    dynamic var departure_time : String = ""
    dynamic var stop_id : Int = -1
    dynamic var stop_sequence : Int = -1
    let stop_headsign : String? = nil
    let pickup_type = RealmOptional<Int>()
    let drop_off_type = RealmOptional<Int>()
    let shape_dist_traveled = RealmOptional<Double>()
    let timepoint = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
