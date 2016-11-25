//
//  GTFSQuery.swift
//  sptransAPI
//
//  Created by resource on 8/12/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import MapKit

class GTFSQuery {
    
    //pragma - MARK: Trips
    
    class func tripsContaining(_ term: String) -> Results<GTFSTrip>  {
        let realm = try! Realm()
        return realm.objects(GTFSTrip.self).filter("route_id CONTAINS[c] %@ OR trip_headsign CONTAINS[c] %@",
                                                   term,
                                                   term)
    }
    
    class func tripsPassingNear(_ point: CLLocation, distance: Double) -> Results<GTFSTrip>{ //distance in meters
        
        var finalSet = Set<Int>()
        
        GTFSQuery.stopsInsideArea(point, radius: distance).tripsForStops()
            .forEach { (trip) in
                guard let shapeID = trip.shape_id.value else {
                    return
                }
                finalSet.insert(shapeID)
        }
        
        let realm = try! Realm()
        return realm.objects(GTFSTrip.self).filter("shape_id IN %@", finalSet)
    }
    
    class func tripsFromLocation(_ start: CLLocation, toDestination end: CLLocation, walkingDistance dist: Double) -> Results<GTFSTrip>{
        let trips = GTFSQuery.tripsPassingNear(start, distance: dist)
            .filter("trip_id IN %@", GTFSQuery.tripsPassingNear(end, distance: dist).value(forKey: "trip_id")!)
            .tripsByDirectionBasedOnLocations(start: start, end: end)
        return trips
    }
    
    //pragma - MARK: Shapes
    
    class func shapesForTrip(_ trip: GTFSTrip) -> Results<GTFSShape> {
        let realm = try! Realm()
        return realm.objects(GTFSShape.self)
            .filter("shape_id == %d", trip.shape_id.value!)
            .sorted(byProperty: "shape_pt_sequence", ascending: true)
    }
    
    //pragma - MARK: Stops
    
    class func stopsInsideArea(_ center: CLLocation, radius: Double) -> Results<GTFSStop> {
        let (maxLat, minLat, maxLon, minLon) = center.boundingBoxForRadius(Float(radius))
        let realm = try! Realm()
        let preFilter = realm.objects(GTFSStop.self)
            .filter("stop_lat BETWEEN {%f, %f} AND stop_lon BETWEEN {%f, %f}",
                    minLat, maxLat, minLon, maxLon)
        
        var finalFilter = Set<Int>()
        for stop in preFilter {
            let stopLocation = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
            if center.distance(from: stopLocation) <= radius {
                finalFilter.insert(stop.stop_id)
            }
        }
        let finalResult = preFilter.filter("stop_id IN %@", finalFilter)
        return finalResult
    }
    
    class func stopsForTrip(_ trip: GTFSTrip) -> Results<GTFSStop>{
        let stopTimes = GTFSQuery.stopTimesForTrip(trip)
        var stopsIDs = Set<Int>()
        for st in stopTimes {
            stopsIDs.insert(st.stop_id)
        }
        let realm = try! Realm()
        return realm.objects(GTFSStop.self).filter("stop_id IN %@", stopsIDs)
    }
    
    class func stopClosestToPoint(_ userLocation: CLLocation) -> GTFSStop {
        let realm = try! Realm()
        let stops = realm.objects(GTFSStop.self)
        var shortestDistance = -1.0;
        var closestStop = GTFSStop()
        for stop in stops {
            let stopLocation = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
            let currentDistance = stopLocation.distance(from: userLocation)
            if shortestDistance < 1 || currentDistance < shortestDistance {
                shortestDistance = currentDistance
                closestStop = stop
            }
        }
        return closestStop
    }
    
    //pragma - MARK: StopTimes
    
    class func stopTimesForTrip(_ trip:GTFSTrip, ordered:Bool = true) -> Results<GTFSStopTime> {
        let realm = try! Realm()
        let r = realm.objects(GTFSStopTime.self).filter("trip_id == %@", trip.trip_id)
        if ordered {
            return r.sorted(byProperty: "stop_sequence", ascending: true)
        }else{
            return r
        }
    }
    
    //pragma - MARK: Legacy reference
    //=========================================================================================
    
    class func legacyTripsPassingNear(_ point: CLLocation, distance: Double) -> Results<GTFSTrip>{
        
        var finalSet = Set<Int>()
        
        //Queries for points inside the bounding box, sorted in a way that groups trips
        //and organizes shapes by their route order
        let realm = try! Realm()
        let shapes = Array(realm.objects(GTFSShape.self)
            .sorted(byProperty: "shape_pt_sequence", ascending: true)
            .sorted(byProperty: "shape_id"))
        
        //Further filtering the returned shapes, testing if the lines they form intersect
        //with the radius we defined.
        autoreleasepool{ for (index, shape) in shapes.enumerated() {
            
            if index != shapes.count - 1 { //Prevents out of bounds exception
                
                let nextShape = shapes[index+1]
                
                //Skips this shape if it's from a different trip OR
                //if the trip is already in range
                if (nextShape.shape_id != shape.shape_id) ||
                    finalSet.contains(shape.shape_id){
                    continue
                }
                
                //Calculates if the shortest distance to this shape is
                //inside the defined radius and saves it's trip ID
                let a = CLLocationCoordinate2D(latitude: shape.shape_pt_lat,
                    longitude: shape.shape_pt_lon)
                let b = CLLocationCoordinate2D(latitude: nextShape.shape_pt_lat,
                    longitude: nextShape.shape_pt_lon)
                if point.shortestDistanceToPath((a, b)) <= distance {
                    finalSet.insert(shape.shape_id)
                }
            }}
        }
        
        return realm.objects(GTFSTrip.self).filter("shape_id IN %@", finalSet)
    }
    
}
