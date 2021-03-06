//
//  GTFSTransfer.swift
//  sptransAPI
//
//  Created by resource on 8/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift

class GTFSTransfer: GTFSBaseModel {
    
    @objc dynamic var from_stop_id : Int = -1
    @objc dynamic var to_stop_id : Int = -1
    @objc dynamic var transfer_type : Int = 0
    let min_transfer_time = RealmOptional<Int>()
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
