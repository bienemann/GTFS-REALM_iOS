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
    
    class func tripsContaining(term: String) -> Results<GTFSTrip>  {
        let realm = try! Realm()
        return realm.objects(GTFSTrip.self).filter("route_id CONTAINS[c] %@ OR trip_headsign CONTAINS[c] %@",
                                                   term,
                                                   term)
    }
    
    class func tripsPassingNear(point: CLLocation, distance: Double) -> Results<GTFSTrip>{ //distance in meters
        
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
    
    class func tripsFromLocation(start: CLLocation, toDestination end: CLLocation, walkingDistance dist: Double) -> Results<GTFSTrip>{
        return GTFSQuery.tripsPassingNear(start, distance: dist)
            .filter("trip_id IN %@", GTFSQuery.tripsPassingNear(end, distance: dist).valueForKey("trip_id")!)
        
    }
    
    //pragma - MARK: Shapes
    
    class func shapesForTrip(trip: GTFSTrip) -> Results<GTFSShape> {
        let realm = try! Realm()
        return realm.objects(GTFSShape.self)
            .filter("shape_id == %d", trip.shape_id.value!)
            .sorted("shape_pt_sequence", ascending: true)
    }
    
    //pragma - MARK: Stops
    
    class func stopsInsideArea(center: CLLocation, radius: Double) -> Results<GTFSStop> {
        let (maxLat, minLat, maxLon, minLon) = center.boundingBoxForRadius(Float(radius))
        let realm = try! Realm()
        let preFilter = realm.objects(GTFSStop.self)
            .filter("stop_lat BETWEEN {%f, %f} AND stop_lon BETWEEN {%f, %f}",
                    minLat, maxLat, minLon, maxLon)
        
        var finalFilter = Set<Int>()
        for stop in preFilter {
            let stopLocation = CLLocation(latitude: stop.stop_lat, longitude: stop.stop_lon)
            if center.distanceFromLocation(stopLocation) <= radius {
                finalFilter.insert(stop.stop_id)
            }
        }
        let finalResult = preFilter.filter("stop_id IN %@", finalFilter)
        return finalResult
    }
    
    //pragma - MARK: Legacy reference
    //=========================================================================================
    
    class func legacyTripsPassingNear(point: CLLocation, distance: Double) -> Results<GTFSTrip>{
        
        var finalSet = Set<Int>()
        
        //Queries for points inside the bounding box, sorted in a way that groups trips
        //and organizes shapes by their route order
        let realm = try! Realm()
        let shapes = Array(realm.objects(GTFSShape.self)
            .sorted("shape_pt_sequence", ascending: true)
            .sorted("shape_id"))
        
        //Further filtering the returned shapes, testing if the lines they form intersect
        //with the radius we defined.
        autoreleasepool{ for (index, shape) in shapes.enumerate() {
            
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