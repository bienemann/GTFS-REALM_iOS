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
    var lines = Array<GTFSTripPolyline>()
    
    override func viewDidAppear(animated: Bool) {
        
        for line in lines {
            self.mapView!.addOverlay(line.renderer.overlay)
        }
        
        self.mapView!.setVisibleMapRect(self.mapRectWithBorder(), animated: true)
    }
    
    func mapRectWithBorder() -> MKMapRect{
        
        var mapRect = MKMapRect()
        if lines.count == 1 {
            mapRect = lines.first!.renderer.overlay.boundingMapRect
        }else{
            for (index, _) in lines.enumerate() {
                if index+1 == lines.count {
                    continue
                }
                
                if index == 0 {
                    mapRect = lines[index].renderer.overlay.boundingMapRect
                }
                
                mapRect = MKMapRectUnion(mapRect, lines[index+1].renderer.overlay.boundingMapRect)
            }
        }
        return MKMapRectMake(mapRect.origin.x - mapRect.size.width/20,
                             mapRect.origin.y - mapRect.size.height/20,
                             mapRect.size.width + mapRect.size.width/10,
                             mapRect.size.height + mapRect.size.height/10)
    }
    
    //MKMapView Delegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        for line in lines {
            if overlay.isEqual(line.renderer.overlay){
                return line.renderer
            }
        }
        
        return MKOverlayRenderer()
    }
    
}
