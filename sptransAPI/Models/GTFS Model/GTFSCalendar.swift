//
//  GTFSCalendar.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class GTFSCalendar: GTFSBaseModel {
    
    dynamic var service_id : String = ""
    dynamic var monday : Bool = false
    dynamic var tuesday : Bool = false
    dynamic var wednesday : Bool = false
    dynamic var thursday : Bool = false
    dynamic var friday : Bool = false
    dynamic var saturday : Bool = false
    dynamic var sunday : Bool = false
    dynamic var start_date : String = ""
    dynamic var end_date : String = ""
    
    override class func typecast() -> ((String, AnyObject) -> AnyObject) {
        return { (key,value) in
            
            if key == "end_date" {
                if value is NSNumber {
                    return value.stringValue!
                }
            }
            
            if  key == "monday" ||
                key == "tuesday" ||
                key == "wednesday" ||
                key == "thursday" ||
                key == "friday" ||
                key == "saturday" ||
                key == "sunday" {
                
                if value is NSNumber {
                    return value.boolValue!
                }
                
            }
            
            return value
        }
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
