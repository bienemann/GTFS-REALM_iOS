//
//  TestMapViewController.swift
//  sptransAPI
//
//  Created by resource on 8/11/16.
//  Copyright © 2016 bienemann. All rights reserved.
//

import Foundation
import MapKit
import SVProgressHUD
import RealmSwift

class TestMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView : MKMapView?
    @IBOutlet weak var firstAddrTxtField : UITextField?
    @IBOutlet weak var secndAddrTxtField : UITextField?
    @IBOutlet weak var btnGo : UIButton?
    
    var lines = Array<GTFSTripPolyline>()
    var circle = Circle()
    var circle2 = Circle()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    var fPlacemarks = Array<CLPlacemark>()
    var sPlacemarks = Array<CLPlacemark>()
    
    override func viewDidLoad() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        firstAddrTxtField?.delegate = self
        secndAddrTxtField?.delegate = self
        btnGo?.layer.cornerRadius = 5.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        for line in lines {
            self.mapView!.add(line.renderer.overlay)
            self.mapView!.addAnnotation(line.lastPointAnnotation)
            self.mapView!.addAnnotation(line.firstPointAnnotation)
        }
        
        let mapRectForLines = GTFSTripPolyline.mapRectForLinesList(lines, borderPercentage: 10)
        self.mapView!.setVisibleMapRect(mapRectForLines, animated: true)
        self.mapView!.showsUserLocation = true
        
//        self.showTripsOnMap()
    }
    
    func showTripsOnMap(_ firstLocation: CLLocation, secondLocation: CLLocation? = nil) {
//        if self.lines.count < 1 {
        
            self.mapView!.removeOverlays(self.mapView!.overlays)
            self.mapView!.removeAnnotations(self.mapView!.annotations)
            
            //near start location: -23.649394,-46.750811
            //near end location: -23.551160,-46.635454
            
//            let testLoc = CLLocation(latitude: -23.439026, longitude: -46.806757)
//            let l = GTFSQuery.tripsPassingNear(testLoc, distance: 1000.0)
//            let p1 = CLLocation(latitude: -23.649394, longitude: -46.750811)
//            let p2 = CLLocation(latitude: -23.551160, longitude: -46.635454)
            
            let p1 = firstLocation
            var l : Results<GTFSTrip>
            if secondLocation != nil {
                l = GTFSQuery.tripsFromLocation(p1, toDestination: secondLocation!, walkingDistance: 500)
            }else{
                l = GTFSQuery.tripsPassingNear(p1, distance: 500)
            }
            
            var a = Array<GTFSTripPolyline>()
            for t in l {
                a.append(GTFSTripPolyline(trip: t))
                print("\(t.route_id) - \(t.trip_headsign!) : \((t.direction_id.value != nil) ? t.direction_id.value! : 99)")
            }
            self.lines = a
            
            circle = Circle(center: p1.coordinate, radius: 200.0)
            circle.renderer = circle.customRenderer()
            self.mapView!.add(circle.renderer!.overlay)
            
            if secondLocation != nil {
                circle2 = Circle(center: secondLocation!.coordinate, radius: 200.0)
                circle2.renderer = circle2.customRenderer()
                self.mapView!.add(circle2.renderer!.overlay)
            }

            for line in lines {
                self.mapView!.add(line.renderer.overlay)
                self.mapView!.addAnnotation(line.lastPointAnnotation)
                self.mapView!.addAnnotation(line.firstPointAnnotation)
            }
            
            let mapRectForLines = GTFSTripPolyline.mapRectForLinesList(lines, borderPercentage: 10)
            self.mapView!.setVisibleMapRect(mapRectForLines, animated: true)
//        }
    }
    
    @IBAction func startGeocoding(){
        
        fPlacemarks.removeAll()
        sPlacemarks.removeAll()
        
        if firstAddrTxtField!.text == nil ||
        firstAddrTxtField!.text!.isEmpty == true {
            SVProgressHUD.setDefaultMaskType(.clear)
            SVProgressHUD.showInfo(withStatus: "primeiro campo deve ser preenchido")
        }else if(secndAddrTxtField!.text == nil ||
            secndAddrTxtField!.text!.isEmpty == true){
            geocoder.geocodeAddressString(firstAddrTxtField!.text!, completionHandler: { (placemark, error) in
                if error != nil {/*tratar erro*/}else{
                    self.fPlacemarks = placemark!
                    self.checkGeocoding()
                }
            })
        }else{
            geocoder.geocodeAddressString(firstAddrTxtField!.text!, completionHandler: { (placemark, error) in
                if error != nil {/*tratar erro*/} else {
                    self.fPlacemarks = placemark!
                    self.geocoder.geocodeAddressString(self.secndAddrTxtField!.text!, completionHandler: { (splacemark, error2) in
                        if error2 != nil {/*tratar erro*/} else {
                            self.sPlacemarks = splacemark!
                            self.checkGeocoding()
                        }
                    })
                }
            })
        }
    }
    
    func checkGeocoding() {
        if self.fPlacemarks.count > 0{
            if self.sPlacemarks.count > 0 {
                GTFSTripPlanner.searchFrom(fPlacemarks.first!.location!, to: sPlacemarks.first!.location!)
                self.showTripsOnMap(fPlacemarks.first!.location!, secondLocation: sPlacemarks.first!.location!)
            }else{
                self.showTripsOnMap(fPlacemarks.first!.location!)
            }
        }
    }
    
    //MARK: - MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // TOOD: tratar
//        self.showTripsOnMap()
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        //tratar
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        if annotation.isKind(of: StartingPointAnnotation.self) {
            return StartingPointAnnotationView(annotation: annotation)
        }
        if annotation.isKind(of: EndPointAnnotation.self){
            return EndPointAnnotationView(annotation: annotation)
        }
        
        return MKAnnotationView()
    }
    
    // MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // TODO: tratar
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO: tratar
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //TODO: tratar
    }
    
    // MARK: - TextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (firstAddrTxtField!.text != nil &&
            firstAddrTxtField!.text!.isEmpty != true) &&
        (secndAddrTxtField!.text != nil &&
            secndAddrTxtField!.text!.isEmpty != true){
            textField.resignFirstResponder()
            self.startGeocoding()
        }else{
            if textField == firstAddrTxtField {
                textField.resignFirstResponder()
            }else if textField == secndAddrTxtField &&
            (firstAddrTxtField!.text != nil &&
                firstAddrTxtField!.text!.isEmpty != true){
                textField.resignFirstResponder()
                self.startGeocoding()
            }else{
                textField.resignFirstResponder()
            }
        }
        
    }
    
}
