//
//  GTFSCalendarDates.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSCalendarDates: GTFSBaseModel {
    
    @objc dynamic var service_id : String = ""
    @objc dynamic var date : String = ""
    @objc dynamic var exception_type : Int = 0
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
