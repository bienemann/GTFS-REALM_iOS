//
//  GTFSAgency.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSAgency: Object {
    
    dynamic var agency_id : String = ""
    dynamic var agency_name : String = ""
    dynamic var agency_url : String = ""
    dynamic var agency_timezone : String = ""
    dynamic var agency_lang : String? = nil
    dynamic var agency_phone : String? = nil
    dynamic var agency_fare_url : String? = nil
    dynamic var agency_email : String? = nil
    
    override static func primaryKey() -> String? {
        return "agency_id"
    }
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
