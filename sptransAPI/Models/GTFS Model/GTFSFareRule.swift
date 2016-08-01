//
//  GTFSFareRule.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFareRule: Object {
    
    dynamic var fare_id  : String = ""
    let route_id = RealmOptional<Int>()
    let origin_id = RealmOptional<Int>()
    let destination_id = RealmOptional<Int>()
    let contains_id = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
