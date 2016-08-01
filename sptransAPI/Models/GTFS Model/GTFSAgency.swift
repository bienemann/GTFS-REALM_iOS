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
    let agency_lang : String? = nil
    let agency_phone : String? = nil
    let agency_fare_url : String? = nil
    let agency_email : String? = nil
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
