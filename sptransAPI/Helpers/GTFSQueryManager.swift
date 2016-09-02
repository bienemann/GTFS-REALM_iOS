//
//  GTFSQueryManager.swift
//  sptransAPI
//
//  Created by resource on 8/12/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation
import MapKit

class GTFSQueryManager {
    
    class func selectTripsContaining(term: String) -> Results<GTFSTrip>  {
        let realm = try! Realm()
        return realm.objects(GTFSTrip.self).filter("route_id CONTAINS[c] %@ OR trip_headsign CONTAINS[c] %@",
                                                   term,
                                                   term)
    }
    
    class func shapesForTrip(trip: GTFSTrip) -> Results<GTFSShape> {
        let realm = try! Realm()
        return realm.objects(GTFSShape.self)
            .filter("shape_id == %d", trip.shape_id.value!)
            .sorted("shape_pt_sequence", ascending: true)
    }
    
    class func tripsPassingNear(point: CLLocation, distance: Double) -> Results<GTFSTrip>{ //distance in meters
        let start = NSDate()
        print("start")
        // Defines a bounding box surrounding the detection radius to "pre-filter"
        // which shapes will be tested.
        //*** IMPORTANT: we multiply the distance by 2.5 arbitrarily to TRY to avoid a situation
        //where a path exists that intersects with our area but is not detected because
        //its starting and ending point falls outside of our radius.
        // *** NEEDS A ~SMARTER~ SOLUTION ***
        let (maxLat, minLat, maxLon, minLon) = point.boundingBoxForRadius(Float(distance * 2.5))
        var finalSet = Set<Int>()
        
        //Queries for points inside the bounding box, sorted in a way that groups trips
        //and organizes shapes by their route order
        let realm = try! Realm()
        let shapes = realm.objects(GTFSShape.self)
            .filter("shape_pt_lat BETWEEN {%f, %f} AND shape_pt_lon BETWEEN {%f, %f}",
                minLat, maxLat, minLon, maxLon)
            .sorted("shape_pt_sequence", ascending: true)
            .sorted("shape_id")
        
        //Further filtering the returned shapes, testing if the lines they form intersect
        //with the radius we defined.
        for (index, shape) in shapes.enumerate() {
            
            if shape != shapes.last! { //Prevents out of bounds exception
                
                //Skips this shape if it's from a different trip OR
                //if the trip is already in range
                if (shapes[index+1].shape_id != shape.shape_id) ||
                finalSet.contains(shape.shape_id){
                    continue
                }
                
                //Calculates if the shortest distance to this shape is
                //inside the defined radius and saves it's trip ID
                let a = CLLocationCoordinate2D(latitude: shape.shape_pt_lat,
                                               longitude: shape.shape_pt_lon)
                let b = CLLocationCoordinate2D(latitude: shapes[index+1].shape_pt_lat,
                                               longitude: shapes[index+1].shape_pt_lon)
                if point.shortestDistanceToPath((a, b)) <= distance {
                    finalSet.insert(shape.shape_id)
                }
            }
        }
        
        let end = NSDate()
        print(end.timeIntervalSinceDate(start))
        return realm.objects(GTFSTrip.self).filter("shape_id IN %@", finalSet)
    }
    
}