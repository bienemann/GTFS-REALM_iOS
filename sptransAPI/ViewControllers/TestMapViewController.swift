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
    
    override func viewDidLoad() {
        self.plotLine(self.line!)
    }
    
    func plotLine(line: GTFSTripPolyline){
        let renderer = MKPolylineRenderer(polyline: line)
        MKPolylineView
        self.mapView?.addOverlay(renderer.overlay)
        self.mapView?.regionThatFits(MKCoordinateRegion(
            center: line.coordinate, span: MKCoordinateSpan(latitudeDelta: 90, longitudeDelta: 90)))
    }
    
}
