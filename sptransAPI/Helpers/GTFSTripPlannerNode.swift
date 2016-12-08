//
//  GTFSTripPlannerNode.swift
//  sptransAPI
//
//  Created by resource on 12/7/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import UIKit
import CoreLocation

class GTFSTripPlannerNode: AnyObject, Hashable {
    
    public let parent : GTFSTripPlannerNode? = nil
    public var children : Set<GTFSTripPlannerNode> = []
    public var stop : GTFSStop?
    public var location : CLLocation
    public var depth = 0
    
    init(_ stop : GTFSStop) {
        self.stop = stop
        self.children = []
        self.location = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
    }
    
    init(_ location : CLLocation) {
        self.location = location
        self.children = []
        self.location = location
    }
    
    public func isLocation() -> Bool {
        return self.stop == nil
    }
    
    //Hashable
    var hashValue: Int {
        var hash = 5381
        if self.parent != nil {
            hash = hash << ObjectIdentifier(self.parent!).hashValue
        }
        for child in self.children {
            hash = hash << ObjectIdentifier(child).hashValue
        }
        if self.stop != nil {
            hash = hash << ObjectIdentifier(self.stop!).hashValue
        }
        
        hash = hash << ObjectIdentifier(self.location).hashValue
        
        return hash
    }
    
    static func ==(lhs: GTFSTripPlannerNode, rhs: GTFSTripPlannerNode) -> Bool {
        return lhs === rhs
    }

}
