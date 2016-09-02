//
//  TestMapViewController.swift
//  sptransAPI
//
//  Created by resource on 8/11/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import MapKit

class TestMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView : MKMapView?
    var lines = Array<GTFSTripPolyline>()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        for line in lines {
            self.mapView!.addOverlay(line.renderer.overlay)
            self.mapView!.addAnnotation(line.lastPointAnnotation)
            self.mapView!.addAnnotation(line.firstPointAnnotation)
        }
        
        let mapRectForLines = GTFSTripPolyline.mapRectForLinesList(lines, borderPercentage: 10)
        self.mapView!.setVisibleMapRect(mapRectForLines, animated: true)
        self.mapView!.showsUserLocation = true
    }
    
    //MARK: - MKMapView Delegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // TOOD: tratar
        if self.lines.count < 1 {
            let l = GTFSQueryManager.tripsPassingNear(self.mapView!.userLocation.location!, distance: 1000.0)
            var a = Array<GTFSTripPolyline>()
            for t in l {
                a.append(GTFSTripPolyline(trip: t))
            }
            self.lines = a
            
            for line in lines {
                self.mapView!.addOverlay(line.renderer.overlay)
                self.mapView!.addAnnotation(line.lastPointAnnotation)
                self.mapView!.addAnnotation(line.firstPointAnnotation)
            }
            
            let mapRectForLines = GTFSTripPolyline.mapRectForLinesList(lines, borderPercentage: 10)
            self.mapView!.setVisibleMapRect(mapRectForLines, animated: true)
        }
        
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        //tratar
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        for line in lines {
            if overlay.isEqual(line.renderer.overlay){
                return line.renderer
            }
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKindOfClass(MKUserLocation.self){
            return nil
        }
        if annotation.isKindOfClass(StartingPointAnnotation.self) {
            return StartingPointAnnotationView(annotation: annotation)
        }
        if annotation.isKindOfClass(EndPointAnnotation.self){
            return EndPointAnnotationView(annotation: annotation)
        }
        
        return MKAnnotationView()
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // TODO: tratar
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO: tratar
    }
    

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //TODO: tratar
    }
    
}
