//
//  GTFSTripPlanner.swift
//  sptransAPI
//
//  Created by resource on 12/6/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import UIKit
import Foundation
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
        
        var stop : Bool = false
        let lock = NSLock()
        
        
        GTFSTripPlanner.traverseTreeFrom(root_A, visitedNodes: &visited_A, stop: &stop) { (depth) in
            print("root_A depth: \(depth)")
            lock.lock()
            let cpA = visited_A; let cpB = visited_B;
            lock.unlock()
            if cpA.intersects(cpB){
                stop = true
            }
        }
        
        GTFSTripPlanner.traverseTreeFrom(root_B, visitedNodes: &visited_B, stop: &stop, isBackwards: true) {(depth) in
            print("root_B depth: \(depth)")
            lock.lock()
            let cpA = visited_A; let cpB = visited_B;
            lock.unlock()
            if cpA.intersects(cpB){
                stop = true
            }
        }
        
    }
    
    class func traverseTreeFrom(_ rootN : Node,
                                visitedNodes : inout NSMutableOrderedSet,
                                stop : inout Bool, isBackwards : Bool = false,
                                executeWhenStepping : @escaping (_ newDepth : Int) -> Void) -> Void {
        
        var queue = Array<Node>()
        var linesContemplated = Set<GTFSTrip>()
        queue.append(rootN)

            let realm = try! Realm()
            while !queue.isEmpty {
                if stop {return}
            
                let currN = queue.removeFirst()
                if !currN.isLocation() {
                    let lines = currN.stop!.trips
                    for line in lines {
                        if linesContemplated.contains(line) { continue }
                        
                        guard let stop = isBackwards ?
                            line.previousStopFrom(currN.stop!) :
                            line.nextStopFrom(currN.stop!) else {
                                return
                        }
                        let newNode = Node(stop)
                        newNode.depth = currN.depth + 1
                        currN.children.insert(newNode)
                        queue.append(newNode)
                        
                        linesContemplated.insert(line)
                    }
                }
                    let stops = realm.objects(GTFSStop.self)
                        .filterWithinDistance(200, fromLocation: currN.location)
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
                    print("queue count: \(queue.count)")
                }

            }

    }
}
