
//
//  File.swift
//  sptransAPI
//
//  Created by resource on 8/12/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import MapKit

class GTFSTripPolyline: MKPolyline {
    
    convenience init(trip: GTFSTrip) {
        
        let shapes = GTFSQueryManager.shapesForTrip(trip)
        var coordinates = Array<CLLocationCoordinate2D>()
        for shape in shapes {
            autoreleasepool({ 
                let coord = CLLocationCoordinate2D(latitude: shape.shape_pt_lat,
                    longitude: shape.shape_pt_lon)
                coordinates.append(coord)
            })
        }
        
        self.init()
        self.init(coordinates: UnsafeMutablePointer(coordinates), count: coordinates.count)
        
    }
    
}