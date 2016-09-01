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
import GLKit
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
    
    /**
     Returns a tuple containing the bounding coordinates for the area provided.
     - parameter center: The center point of the desired bounds.
     - parameter distance: The radius (in meters) from the center.
     - parameter multiplier: Multiplies the radius value. Default is 1.
     - returns: A tuple containing the four points that make the bounding box that contains the wole area defined.
     */
    class func boundingBoxForArea(center: CLLocation, distance: Double, multiplier: Int = 1) -> (Float, Float, Float, Float){
        
        let R : Float = 6371000.0
        let largerDistance = Float(distance) * Float(multiplier)
        let distanceByRDeg = Double(GLKMathRadiansToDegrees(largerDistance/R))
        let arcSinOfDBR = asin(largerDistance/R)
        
        let radCosLat = cos(GLKMathDegreesToRadians(Float(center.coordinate.latitude)))
        let radCosLon = cos(GLKMathDegreesToRadians(Float(center.coordinate.longitude)))
        
        let maxLat = center.coordinate.latitude + distanceByRDeg
        let minLat = center.coordinate.latitude - distanceByRDeg
        let maxLon = Float(center.coordinate.longitude) + GLKMathRadiansToDegrees(arcSinOfDBR / radCosLat)
        let minLon = Float(center.coordinate.longitude) - GLKMathRadiansToDegrees(arcSinOfDBR / radCosLon)
        
        return (Float(maxLat), Float(minLat), maxLon, minLon)
    }
    
    class func closestLocationInSegment(line: (CLLocationCoordinate2D, CLLocationCoordinate2D), point: CLLocationCoordinate2D) -> CLLocation {
        
        let (A, B) = line
        let dAP : (x: Double, y: Double) = (point.latitude - A.latitude, point.longitude - A.longitude)
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
    
    class func linesNearPoint(point: CLLocation, distance: Double) -> Results<GTFSTrip>{ //distance in meters
        
        let (maxLat, minLat, maxLon, minLon) = GTFSQueryManager.boundingBoxForArea(point, distance: distance)
        
        let realm = try! Realm()
        let shapes = realm.objects(GTFSShape.self).filter("shape_pt_lat BETWEEN {%f, %f} AND shape_pt_lon BETWEEN {%f, %f}", Float(minLat), Float(maxLat), Float(minLon), Float(maxLon))
            .sorted("shape_pt_sequence", ascending: true)
            .sorted("shape_id")
        
        var finalSet = Set<Int>()
        
        for (index, shape) in shapes.enumerate() {
            if shape != shapes.last! {
                
                if (shapes[index+1].shape_id != shape.shape_id) ||
                finalSet.contains(shape.shape_id){
                    continue
                }
                
                let a = CLLocationCoordinate2D(latitude: shape.shape_pt_lat,
                                               longitude: shape.shape_pt_lon)
                let b = CLLocationCoordinate2D(latitude: shapes[index+1].shape_pt_lat,
                                               longitude: shapes[index+1].shape_pt_lon)
                let closest = GTFSQueryManager.closestLocationInSegment((a, b), point: point.coordinate)
                let d = closest.distanceFromLocation(point)
                if d <= distance {
                    finalSet.insert(shape.shape_id)
                }
            }
        }
        
        let lines = realm.objects(GTFSTrip.self).filter("shape_id IN %@", finalSet)
        
        return lines
    }
    
}