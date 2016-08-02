//
//  GTFSFrequency.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFrequency: Object {
    
    dynamic var trip_id : String = ""
    dynamic var start_time : String = ""
    dynamic var end_time : String = ""
    dynamic var headway_secs : Int = 0
    let exact_times = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
