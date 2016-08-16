//
//  TestMapViewController.swift
//  sptransAPI
//
//  Created by resource on 8/11/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import MapKit

class TestMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView : MKMapView?
    var line : GTFSTripPolyline? = nil
    var lineRenderer : MKPolylineRenderer?
    
    override func viewDidAppear(animated: Bool) {
        if self.line != nil{
            self.lineRenderer = self.customLineRenderer(self.line!)
            self.mapView!.addOverlay(self.lineRenderer!.overlay)
            self.mapView!.setVisibleMapRect(self.mapRectWithBorder(self.lineOverlay()!), animated: true)
        }
    }
    
    func lineOverlay() -> MKOverlay?{
        if self.lineRenderer != nil {
            return self.lineRenderer!.overlay
        }else{
            return nil
        }
    }
    
    func mapRectWithBorder(overlay: MKOverlay) -> MKMapRect{
        let mapRect = overlay.boundingMapRect
        return MKMapRectMake(mapRect.origin.x - mapRect.size.width/20,
                             mapRect.origin.y - mapRect.size.height/20,
                             mapRect.size.width + mapRect.size.width/10,
                             mapRect.size.height + mapRect.size.height/10)
    }
    
    func customLineRenderer(line: GTFSTripPolyline) -> MKPolylineRenderer{
        let renderer = MKPolylineRenderer(polyline: line)
        renderer.strokeColor = UIColor.redColor()
        renderer.lineWidth = 5
        return renderer
    }
    
    //MKMapView Delegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isEqual(self.lineRenderer!.overlay)  {
            return self.lineRenderer!
        }
        return MKOverlayRenderer()
    }
    
}
