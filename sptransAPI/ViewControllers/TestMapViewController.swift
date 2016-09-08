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
    var circle = Circle()
    var circle2 = Circle()
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
        
        self.showTripsOnMap()
    }
    
    func showTripsOnMap() {
        if self.lines.count < 1 {
            
            //near start location: -23.649394,-46.750811
            //near end location: -23.551160,-46.635454
            
//            let testLoc = CLLocation(latitude: -23.439026, longitude: -46.806757)
//            let l = GTFSQuery.tripsPassingNear(testLoc, distance: 1000.0)
            let p1 = CLLocation(latitude: -23.649394, longitude: -46.750811)
            let p2 = CLLocation(latitude: -23.551160, longitude: -46.635454)
            let l = GTFSQuery.tripsFromLocation(p1, toDestination: p2, walkingDistance: 200)
            var a = Array<GTFSTripPolyline>()
            for t in l {
                a.append(GTFSTripPolyline(trip: t))
                print("\(t.route_id) - \(t.trip_headsign!) : \((t.direction_id.value != nil) ? t.direction_id.value! : 99)")
            }
            self.lines = a
            
            circle = Circle(centerCoordinate: p1.coordinate, radius: 200.0)
            circle.renderer = circle.customRenderer()
            circle2 = Circle(centerCoordinate: p2.coordinate, radius: 200.0)
            circle2.renderer = circle2.customRenderer()
            self.mapView!.addOverlay(circle.renderer!.overlay)
            self.mapView!.addOverlay(circle2.renderer!.overlay)
            
            for line in lines {
                self.mapView!.addOverlay(line.renderer.overlay)
                self.mapView!.addAnnotation(line.lastPointAnnotation)
                self.mapView!.addAnnotation(line.firstPointAnnotation)
            }
            
            let mapRectForLines = GTFSTripPolyline.mapRectForLinesList(lines, borderPercentage: 10)
            self.mapView!.setVisibleMapRect(mapRectForLines, animated: true)
        }
    }
    
    //MARK: - MKMapView Delegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        // TOOD: tratar
        self.showTripsOnMap()
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
        
        if overlay.isEqual(circle.renderer!.overlay) {
            return circle.renderer!
        }
        if overlay.isEqual(circle2.renderer!.overlay) {
            return circle2.renderer!
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
