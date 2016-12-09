//
//  FareAttribute.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFareAttribute: GTFSBaseModel {
    
    dynamic var fare_id : String = ""
    dynamic var price : Double = 0.0
    dynamic var currency_type : String = ""
    dynamic var payment_method : Int = 999
    dynamic var transfers : String = ""
    var transfer_duration = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "fare_id"
    }
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "transfer_duration": fallthrough
            case "payment_method":
                if value is NSNumber {
                    return value
                }else{ return value }
            default:
                return value
            }
            
        }
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
