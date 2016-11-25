
//
//  GTFSMapUtilities.swift
//  sptransAPI
//
//  Created by resource on 8/12/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import MapKit

class Circle : MKCircle {
    
    var renderer : MKCircleRenderer?
    
    func customRenderer() -> MKCircleRenderer{
        let renderer = MKCircleRenderer(circle: self)
        renderer.strokeColor = UIColor.green
        renderer.fillColor = UIColor.green.withAlphaComponent(0.3)
        return renderer
    }
    
}

// MARK: - Polyline

class GTFSTripPolyline: MKPolyline {
    
    var renderer : MKPolylineRenderer = MKPolylineRenderer()
    var lastPointAnnotation : EndPointAnnotation = EndPointAnnotation()
    var firstPointAnnotation : StartingPointAnnotation = StartingPointAnnotation()
    
    override init() {
        super.init()
    }
    
    convenience init(trip: GTFSTrip) {
        
        let shapes = GTFSQuery.shapesForTrip(trip)
        var coordinates = Array<CLLocationCoordinate2D>()
        for shape in shapes {
            autoreleasepool(invoking: { 
                let coord = CLLocationCoordinate2D(latitude: shape.shape_pt_lat,
                    longitude: shape.shape_pt_lon)
                coordinates.append(coord)
            })
        }
        
        self.init()
        self.init(coordinates: UnsafeMutablePointer(mutating: coordinates), count: coordinates.count)
        
        self.renderer = self.customLineRenderer(self)
        self.firstPointAnnotation = StartingPointAnnotation(lat: shapes.first!.shape_pt_lat,
                                                            lon: shapes.first!.shape_pt_lon)
        self.lastPointAnnotation = EndPointAnnotation(lat: shapes.last!.shape_pt_lat,
                                                       lon: shapes.last!.shape_pt_lon)
    }
    
    func customLineRenderer(_ line: GTFSTripPolyline) -> MKPolylineRenderer{
        let renderer = MKPolylineRenderer(polyline: line)
        renderer.strokeColor = UIColor(red: 0.23, green: 0.36, blue: 0.75, alpha: 0.5)
        renderer.lineWidth = 3
        renderer.lineCap = CGLineCap.square
        return renderer
    }
    
    class func mapRectForLinesList(_ lines:Array<GTFSTripPolyline>, borderPercentage: Int) -> MKMapRect{
        
        var mapRect = MKMapRect()
        if lines.count == 1 {
            mapRect = lines.first!.renderer.overlay.boundingMapRect
        }else{
            for (index, _) in lines.enumerated() {
                if index+1 == lines.count {
                    continue
                }
                
                if index == 0 {
                    mapRect = lines[index].renderer.overlay.boundingMapRect
                }
                
                mapRect = MKMapRectUnion(mapRect, lines[index+1].renderer.overlay.boundingMapRect)
            }
        }
        return MKMapRectMake(mapRect.origin.x - mapRect.size.width/(Double(borderPercentage)*2),
                             mapRect.origin.y - mapRect.size.height/(Double(borderPercentage)*2),
                             mapRect.size.width + mapRect.size.width/Double(borderPercentage),
                             mapRect.size.height + mapRect.size.height/Double(borderPercentage))
    }
}

// MARK: - Point Annotations

class LinePointAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    override init() {
        self.coordinate = CLLocationCoordinate2D()
    }
    
    init(lat: Double, lon: Double){
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
class StartingPointAnnotation: LinePointAnnotation {}
class EndPointAnnotation: LinePointAnnotation {}
class BusLocationAnnotation: LinePointAnnotation {}
class StopLocationAnnotation: LinePointAnnotation {}

// MARK: - Annotation Views

class StartingPointAnnotationView: MKPinAnnotationView {
    init(annotation: MKAnnotation){
        super.init(annotation: annotation, reuseIdentifier: "start_point_pin_identifier")
        if #available(iOS 9.0, *) {
            self.pinTintColor = UIColor.green
        } else {
            self.pinColor = MKPinAnnotationColor.green
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EndPointAnnotationView: MKPinAnnotationView {
    init(annotation: MKAnnotation){
        super.init(annotation: annotation, reuseIdentifier: "end_point_pin_identifier")
        if #available(iOS 9.0, *) {
            self.pinTintColor = UIColor.red
        } else {
            self.pinColor = MKPinAnnotationColor.red
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
