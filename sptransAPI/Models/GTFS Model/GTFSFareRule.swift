//
//  GTFSFareRule.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFareRule: GTFSBaseModel {
    
    dynamic var fare_id  : String = ""
    dynamic var route_id : String? = nil
    dynamic var origin_id : String? = nil
    dynamic var destination_id : String? = nil
    dynamic var contains_id : String? = nil
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
