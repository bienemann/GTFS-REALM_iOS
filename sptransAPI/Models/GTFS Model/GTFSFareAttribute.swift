//
//  FareAttribute.swift
//  sptransAPI
//
//  Created by resource on 8/1/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSFareAttribute: Object {
    
    dynamic var fare_id : String = ""
    dynamic var price : Double = 0.0
    dynamic var currency_type : String = ""
    dynamic var payment_method : Int = 999
    dynamic var transfers : String = ""
    var transfer_duration = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
