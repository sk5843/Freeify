//
//  MapViewController.swift
//  babyhaha
//
//  Created by Sai~ on 12/6/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RangeRadiusMKMapView

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    var mapView2:RangeRadiusMKMapView!
    var distanceLabel:UILabel!
    var exitButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        determineCurrentLocation()
        
    
    }
    
    func  createDistanceLabelOnMap(){
        distanceLabel = UILabel(frame: CGRect(x: 16, y: 44, width: 141, height: 28))
        distanceLabel.backgroundColor = .clear
        distanceLabel.textColor = UIColor.black
        distanceLabel.textAlignment = NSTextAlignment.left
        self.mapView2.addSubview(distanceLabel)
    }
    
    func createExitButtonOnMap(){
        exitButton = UIButton(frame: CGRect(x: 320, y: 44, width: 30, height: 30))
        exitButton.backgroundColor = .clear
        exitButton.setImage(UIImage(named: "cross2"), for: .normal)
        exitButton.showsTouchWhenHighlighted = true
        //Set Attributes
        exitButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        exitButton.layer.masksToBounds = false
        exitButton.layer.shadowColor = UIColor.black.cgColor
        exitButton.layer.shadowRadius = 3.0
        exitButton.layer.shadowOpacity = 0.9
        exitButton.addTarget(self, action: #selector(exitbuttonAction), for: .touchUpInside)
        self.view.addSubview(exitButton)
    }
    
    @objc func exitbuttonAction(sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        setMapView(location: center)
        self.mapView2.setRegion(region, animated: true)
        self.mapView2.addAnnotation(myAnnotation)
        createExitButtonOnMap()
        createDistanceLabelOnMap()
        manager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error \(error)")
    }
    func setMapView(location: CLLocationCoordinate2D){
        self.mapView2 = RangeRadiusMKMapView(frame: .zero, delegate: self)
        self.view.addSubview(mapView2)
        
        self.mapView2.setRadiusWithRange(centerCoordinate: location, startRadius: 200, minRadius: 100, maxRadius: 10000)
        self.mapView2.rangeIsActive = true
        
        let coordRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView2.setRegion(coordRegion, animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.mapView2 != nil {
            self.mapView2.frame = self.view.bounds
        }
    }
    internal func setRangeTitle(_ range: Double) {
        
        var distance = String()
        distance = String(format: "%.02f miles", range/1609.34)
        
        self.distanceLabel.text = "Range: \(distance)"
        self.distanceLabel.font = UIFont(name: "Avenir-Black", size: 16)
        
    }
    
    

}
extension MapViewController : MKRadiusDelegate {
    func onRadiusChange(_ radius: Double) {
        self.setRangeTitle(radius)
    }
}
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let properties = RangeRadiusProperties(fillColor: UIColor.red, alpha: 0.5, border: 50, borderColor: UIColor.black)
        return self.mapView2.getRenderer(from: overlay, properties: properties)
    }
}
