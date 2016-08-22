
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
    
    var renderer : MKPolylineRenderer = MKPolylineRenderer()
    
    override init() {
        super.init()
    }
    
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
        
        self.renderer = self.customLineRenderer(self)
        
    }
    
    func customLineRenderer(line: GTFSTripPolyline) -> MKPolylineRenderer{
        let renderer = MKPolylineRenderer(polyline: line)
        renderer.strokeColor = UIColor(red: 0.23, green: 0.36, blue: 0.75, alpha: 0.5)
        renderer.lineWidth = 3
        renderer.lineCap = CGLineCap.Square
        return renderer
    }
    
}