//
//  GTFSCalendar.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSCalendar: Object {
    
    dynamic var service_id : String = ""
    dynamic var monday = false
    dynamic var tuesday = false
    dynamic var wednesday = false
    dynamic var thursday = false
    dynamic var friday = false
    dynamic var saturday = false
    dynamic var sunday = false
    dynamic var start_date : String = ""
    dynamic var end_date : String = ""
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
