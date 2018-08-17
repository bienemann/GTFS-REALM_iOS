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
    
    @objc dynamic var service_id : String = ""
    @objc dynamic var monday : Bool = false
    @objc dynamic var tuesday : Bool = false
    @objc dynamic var wednesday : Bool = false
    @objc dynamic var thursday : Bool = false
    @objc dynamic var friday : Bool = false
    @objc dynamic var saturday : Bool = false
    @objc dynamic var sunday : Bool = false
    @objc dynamic var start_date : String = ""
    @objc dynamic var end_date : String = ""
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
//            if key == "end_date" {
//                if value is NSNumber {
//                    return (value as! NSNumber).stringValue
//                }
//            }
            
            if  key == "monday" ||
                key == "tuesday" ||
                key == "wednesday" ||
                key == "thursday" ||
                key == "friday" ||
                key == "saturday" ||
                key == "sunday" {
                
                if let intValue = Int(value as! String) {
                    return intValue != 0
                }
                
                return value
                
            }
            
            return value
        }
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
