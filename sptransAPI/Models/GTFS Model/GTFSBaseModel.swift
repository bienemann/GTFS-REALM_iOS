//
//  GTFSBaseModel.swift
//  sptransAPI
//
//  Created by resource on 8/9/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

open class GTFSBaseModel: Object {
    
    required public init(values: Array<Any>, keys: Array<String>, typecast:((String, Any)->Any)){
        
        var d = Dictionary<String, Any>()
        for (index,key) in keys.enumerated() {
            d.updateValue(typecast(key, values[index]), forKey: key)
        }
        super.init(value: d)
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        fatalError("init(value:schema:) has not been implemented")
    }
    
    class func typecast() -> ((String, Any)->Any) {
        return { (_,value) in
            return value
        }
    }
    
}
