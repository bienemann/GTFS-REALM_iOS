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
    
    @objc dynamic var fare_id : String = ""
    @objc dynamic var price : Double = 0.0
    @objc dynamic var currency_type : String = ""
    @objc dynamic var payment_method : Int = 999
    @objc dynamic var transfers : String = ""
    var transfer_duration = RealmOptional<Int>()
    
    override static func primaryKey() -> String? {
        return "fare_id"
    }
    
    override class func typecast() -> ((String, Any) -> Any) {
        return { (key,value) in
            
            switch key {
            case "transfer_duration": fallthrough
            case "payment_method":
                return Int(value as! String)
            case "price":
                return Double(value as! String)
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
