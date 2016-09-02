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

extension CLLocation {
    
    /**
     Returns a tuple containing the bounding coordinates for the area provided.
     Works with single precision float.
     - parameter radius: The radius (in meters) from the center.
     - returns: A tuple containing the four points that make the bounding box that contains the wole area defined.
     */
    public func boundingBoxForRadius(radius: Float) -> (Float, Float, Float, Float){
        
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
    public func closestLocationInPath(path:(CLLocationCoordinate2D, CLLocationCoordinate2D)) -> CLLocation {
        
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
    public func shortestDistanceToPath(path:(CLLocationCoordinate2D, CLLocationCoordinate2D)) -> CLLocationDistance{
        return self.distanceFromLocation(self.closestLocationInPath(path))
    }
}