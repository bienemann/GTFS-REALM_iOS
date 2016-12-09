//
//  GTFSExtensions.swift
//  sptransAPI
//
//  Created by resource on 9/2/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import CoreLocation
import GLKit
import RealmSwift
import Realm

extension CLLocation {
    
    /**
     Returns a tuple containing the bounding coordinates for the area provided.
     Works with single precision float.
     - parameter radius: The radius (in meters) from the center.
     - returns: A tuple containing the four points that make the bounding box that contains the wole area defined.
     */
    public func boundingBoxForRadius(_ radius: Float) -> (Float, Float, Float, Float){
        
        let R : Float = 6371000.0
        let distanceByRDeg = GLKMathRadiansToDegrees(radius/R)
        let arcSinOfDBR = asin(radius/R)
        
        let radCosLat = cos(GLKMathDegreesToRadians(Float(self.coordinate.latitude)))
        let radCosLon = cos(GLKMathDegreesToRadians(Float(self.coordinate.longitude)))
        
        let maxLat = Float(self.coordinate.latitude) + distanceByRDeg
        let minLat = Float(self.coordinate.latitude) - distanceByRDeg
        let maxLon = Float(self.coordinate.longitude) + GLKMathRadiansToDegrees(arcSinOfDBR / radCosLat)
        let minLon = Float(self.coordinate.longitude) - GLKMathRadiansToDegrees(arcSinOfDBR / radCosLon)
        
        return (Float(maxLat), Float(minLat), maxLon, minLon)
    }
    
    /**
     Calculates the closest point from self inside the given path segment.
     - parameter path: The coordinates for point A and B of the segment inside a tuple (A, B)
     - returns: The CLLocation inside the path and closest to self.
     */
    public func closestLocationInPath(_ path:(CLLocationCoordinate2D, CLLocationCoordinate2D)) -> CLLocation {
        
        let (A, B) = path
        let dAP : (x: Double, y: Double) = (self.coordinate.latitude - A.latitude,
                                            self.coordinate.longitude - A.longitude)
        let dAB : (x: Double, y: Double) = (B.latitude - A.latitude, B.longitude - A.longitude)
        
        let dot = dAP.x * dAB.x + dAP.y * dAB.y
        let sqrLen = dAB.x * dAB.x + dAB.y * dAB.y
        let param = dot / sqrLen
        
        var nearest : (x: Double, y: Double) = (0.0,0.0)
        if (param < 0 || (A.longitude == B.latitude && A.longitude == B.longitude)) {
            nearest.x = A.latitude
            nearest.y = A.longitude
        } else if (param > 1) {
            nearest.x = B.latitude
            nearest.y = B.longitude
        } else {
            nearest.x = A.latitude + param * dAB.x;
            nearest.y = A.longitude + param * dAB.y;
        }
        
        let nearestLocation = CLLocation(latitude: nearest.x, longitude: nearest.y)
        return nearestLocation
    }
    
    /**
     Returns the shortest distance from self to a path segment.
     - parameter path: The coordinates for point A and B of the segment inside a tuple (A, B)
     - returns: The shortest distance from self to a path segment.
     */
    public func shortestDistanceToPath(_ path:(CLLocationCoordinate2D, CLLocationCoordinate2D)) -> CLLocationDistance{
        return self.distance(from: self.closestLocationInPath(path))
    }
}

extension GTFSStop {
    
    func distanceToLocation(_ location: CLLocation) -> Double {
        let stopLocation = CLLocation(latitude: self.stop_lat, longitude: self.stop_lon)
        return stopLocation.distance(from: location)
    }
    
    func servicingTrips() -> Results<GTFSTrip> {
        
        let realm = try! Realm()
        let sTimes = realm.objects(GTFSStopTime.self).filter("stop_id == %@", self.stop_id)
        let trips = realm.objects(GTFSTrip.self).filter("trip_id IN %@", sTimes.value(forKey: "trip_id")!)
        return trips
        
    }
    
    func isBefore(_ stop : GTFSStop, inTrip trip : GTFSTrip, forwardTrip reverse : Bool) -> Bool {
        
        let stopTimes = trip.stopTimes()
        let refSequence = stopTimes.filter("stop_id == %@", stop.stop_id).first!.stop_sequence
        let selfSequence = stopTimes.filter("stop_id == %@", self.stop_id).first!.stop_sequence
        
        return reverse ? selfSequence > refSequence : selfSequence < refSequence
        
    }
}

extension GTFSTrip {
    
    func stopTimes() -> Results<GTFSStopTime> {
        let realm = try! Realm()
        return realm.objects(GTFSStopTime.self)
            .filter("trip_id == %@", self.trip_id)
    }
    
    func stops() -> Results<GTFSStop> {
        let realm = try! Realm()
        return realm.objects(GTFSStop.self)
            .filter("stop_id IN %@", self.stopTimes().value(forKey: "stop_id")!)
            .sorted(byProperty: "stop_sequence", ascending: true)
    }
    
    func stopFrom(_ stop : GTFSStop, next isNext : Bool) -> GTFSStop? {
        
        let stops = self.stopTimes()
        
        guard let stopTime = stops.filter("stop_id == %@", stop.stop_id).first else {
            return nil
        }
        
        var sequence : Int
        if isNext {
            sequence = stopTime.stop_sequence+1
        }else{
            sequence = stopTime.stop_sequence-1
        }
        
        guard let next = stops.filter("stop_sequence == %@", sequence).first else {
            return nil
        }
        
        let realm = try! Realm()
        return realm.objects(GTFSStop.self).filter("stop_id == %@", next.stop_id).first
    }
    
    func nextStopFrom(_ stop : GTFSStop) -> GTFSStop? {
        return self.stopFrom(stop, next: true)
    }
    
    func previousStopFrom(_ stop : GTFSStop) -> GTFSStop? {
        return self.stopFrom(stop, next: false)
    }
}


extension Results where T:GTFSStop {
    
    func tripsForStops() -> Results<GTFSTrip>{
        let realm = try! Realm()
        let stopTimes = realm.objects(GTFSStopTime.self).filter("stop_id IN %@", self.value(forKey: "stop_id")!)
        return realm.objects(GTFSTrip.self).filter("trip_id IN %@", stopTimes.value(forKey: "trip_id")!)
    }
    
    func closestStopFromLocation(_ location : CLLocation) -> GTFSStop {
        var shortestDistance = -1.0;
        var closestStop = GTFSStop()
        for stop in self {
            let stopLocation = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
            let currentDistance = stopLocation.distance(from: location)
            if shortestDistance < 1 || currentDistance < shortestDistance {
                shortestDistance = currentDistance
                closestStop = stop
            }
        }
        return closestStop
    }
    
    func filterWithinDistance(_ distance : Float, fromLocation location : CLLocation)
        -> Results<GTFSStop> {
            
            let (maxLat, minLat, maxLon, minLon) = location.boundingBoxForRadius(distance)
            let realm = try! Realm()
            return realm.objects(GTFSStop.self)
                .filter("stop_lat BETWEEN {%f, %f} AND stop_lon BETWEEN {%f, %f}",
                        minLat, maxLat, minLon, maxLon)
            
//            var finalFilter = Set<Int>()
//            for stop in preFilter {
//                let stopLocation = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
//                let current = stopLocation.distance(from: location)
//                let max = CLLocationDistance(distance)
//                if current <= max {
//                    finalFilter.insert(stop.stop_id)
//                }
//            }
//            
//            let finalResult = preFilter.filter("stop_id IN %@", finalFilter)
//            return finalResult
    }
}

extension Results where T:GTFSTrip {
    
    func tripsByDirectionBasedOnLocations(start:CLLocation, end:CLLocation)
        -> Results<T>{
            let realm = try! Realm()
            let stopTimes = realm.objects(GTFSStopTime.self).filter("trip_id IN %@", self.value(forKey: "trip_id")!)
            let stops = realm.objects(GTFSStop.self).filter("stop_id IN %@", stopTimes.value(forKey: "stop_id")!)
            var tripsToReturn = Set<String>()
            for trip in self {
                let stopTimesForTrip = stopTimes.filter("trip_id == %@", trip.trip_id)
                let stopsForTrip = stops.filter("stop_id IN %@", stopTimesForTrip.value(forKey: "stop_id")!)
                let closestToStart = stopsForTrip.closestStopFromLocation(start)
                let closestToFinish = stopsForTrip.closestStopFromLocation(end)
                let startSeq = stopTimesForTrip.filter("stop_id == %d", closestToStart.stop_id).first!.stop_sequence
                let endSeq = stopTimesForTrip.filter("stop_id == %d", closestToFinish.stop_id).first!.stop_sequence
                if endSeq > startSeq {
                    tripsToReturn.insert(trip.trip_id)
                }
            }
            
            return self.filter("trip_id IN %@", tripsToReturn)
    }
    
}
