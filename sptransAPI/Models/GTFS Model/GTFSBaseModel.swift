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

public class GTFSBaseModel: Object {
    
    required public init(values: Array<AnyObject>, keys: Array<String>, typecast:((String, AnyObject)->AnyObject)){
        
        var d = Dictionary<String, AnyObject>()
        for (index,key) in keys.enumerate() {
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
    
    required public init(value: AnyObject, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    class func typecast() -> ((String, AnyObject)->AnyObject) {
        return { (_,value) in
            return value
        }
    }
    
}