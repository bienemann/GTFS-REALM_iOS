//
//  GTFSTripPlanner.swift
//  sptransAPI
//
//  Created by resource on 12/6/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class GTFSTripPlanner: NSObject {
    
    typealias Node = GTFSTripPlannerNode
    typealias Line = GTFSTrip
    
    class func searchFrom(_ location_A : CLLocation, to location_B : CLLocation){
        
        var visited_A = NSMutableOrderedSet()
        var visited_B = NSMutableOrderedSet()
        
        let root_A = Node(location_A)
        let root_B = Node(location_B)
        
        var stop = false
        
        GTFSTripPlanner.traverseTreeFrom(root_A, visitedNodes: &visited_A, stop: &stop) { (depth) in
            if visited_A.intersects(visited_B){
                stop = true
            }
        }
        GTFSTripPlanner.traverseTreeFrom(root_B, visitedNodes: &visited_B, stop: &stop) {_ in }
    }
    
    class func traverseTreeFrom(_ rootN : Node,
                                visitedNodes : inout NSMutableOrderedSet,
                                stop : inout Bool, isBackwards : Bool = false,
                                executeWhenStepping : @escaping (_ newDepth : Int) -> Void) -> Void {
        
        if stop { return }
        
        var queue = Array<Node>()
        queue.append(rootN)
        
        let realm = try! Realm()
        
        while !queue.isEmpty {
            let currN = queue.removeFirst()
            if !currN.isLocation() {
                let lines = currN.stop!.trips
                for line in lines {
                    let stop = isBackwards ?
                        line.previousStopFrom(currN.stop!) :
                        line.nextStopFrom(currN.stop!)
                    let newNode = Node(stop!)
                    newNode.depth = currN.depth + 1
                    currN.children.insert(newNode)
                    queue.append(newNode)
                }
            }
            let stops = realm.objects(GTFSStop.self)
                .filterWithinDistance(500, fromLocation: currN.location)
            for stop in stops {
                let newNode = Node(stop)
                newNode.depth = currN.depth + 1
                if !currN.children.contains(newNode){
                    currN.children.insert(newNode)
                }
                if !queue.contains(newNode) {
                    queue.append(newNode)
                }
            }
            
            var newLevel = false
            if visitedNodes.count > 0 {
                let n = visitedNodes.firstObject as! Node
                newLevel = n.depth != currN.depth
            }
            
            visitedNodes.insert(currN, at: 0)
            
            if newLevel {
                executeWhenStepping(currN.depth)
            }
        }
    }
}
