//
//  GTFSAgency.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSAgency: GTFSBaseModel {
    
    @objc dynamic var agency_id : String = ""
    @objc dynamic var agency_name : String = ""
    @objc dynamic var agency_url : String = ""
    @objc dynamic var agency_timezone : String = ""
    @objc dynamic var agency_lang : String? = nil
    @objc dynamic var agency_phone : String? = nil
    @objc dynamic var agency_fare_url : String? = nil
    @objc dynamic var agency_email : String? = nil
    
    override static func primaryKey() -> String? {
        return "agency_id"
    }
    
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
