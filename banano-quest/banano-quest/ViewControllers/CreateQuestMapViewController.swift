//
//  CreateQuestMapViewController.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/18/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CreateQuestMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var selectedLocation = [AnyHashable: Any]()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Map settings
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        // Location Manager settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // Checks is location services are enabled to start updating location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }else{
            let alertView = self.bananoAlertView(title: "Error", message: "Location services are disabled, please enable before trying again.")
            self.present(alertView, animated: false, completion: nil)
            print("Location services are disabled, please enable before trying again.")
        }
        
        // Gesture for map tap
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.handleTap))
        gestureRecognizer.delegate = self
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh view
        do {
            try refreshView()
        } catch  {
          print("CreateQuestMapViewController - viewWillApper(), failed to call refreshView()")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set current location as default quest location
        currentLocationPressed(self)
    }
    
    // MARK: - Tools
    override func refreshView() throws {
        // UI Elements should be updated here
    }
    
    // MARK: - Gestures
    @objc func handleTap(gestureReconizer: UIGestureRecognizer) {
        
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        selectedLocation["lat"] = annotation.coordinate.latitude.description
        selectedLocation["lon"] = annotation.coordinate.longitude.description

        mapView.addAnnotation(annotation)
    }
    
    // MARK: - MKMapView
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
            if let annotationCoordinate = view.annotation?.coordinate {
                selectedLocation["lat"] = annotationCoordinate.latitude.description
                selectedLocation["lon"] = annotationCoordinate.longitude.description
            }
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let annotationView = MKAnnotationView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 55))
        let imageView = UIImageView(frame: CGRect(x: 1, y: -14, width: 40, height: 40))
        
        imageView.image = UIImage(named: "BANANO-PIN")
        annotationView.addSubview(imageView)
        annotationView.annotation = annotation
        annotationView.canShowCallout = false
        annotationView.isDraggable = true
        
        return annotationView
    }
    
    // MARK: - Location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update
        if locations.count > 0 {
            let location = locations.last!
            
            print("Accuracy: \(location.horizontalAccuracy)")
            if location.horizontalAccuracy < 100 {
                
                manager.stopUpdatingLocation()
                // span: is how much it should zoom into the user location
                let span = MKCoordinateSpan(latitudeDelta: 0.010, longitudeDelta: 0.010)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                // updates map with current user location
                mapView.setRegion(region, animated: true)
                
            }else{
                print("Location accuracy is not under 100 meters, skipping...")
            }
        }else{
            let alertView = self.bananoAlertView(title: "Error", message: "Failed to get current location.")
            self.present(alertView, animated: false, completion: nil)
            
            print("Failed to get current location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            let alertView = self.bananoAlertView(title: "Error", message: "Restricted by parental controls. User can't enable Location Services.")
            self.present(alertView, animated: false, completion: nil)
            
            print("restricted by e.g. parental controls. User can't enable Location Services")
            break
        case .denied:
            // user denied your app access to Location Services, but can grant access from Settings.app
            let alertView = self.bananoAlertView(title: "Error", message: "User denied your app access to Location Services, but can grant access from Settings.app.")
            self.present(alertView, animated: false, completion: nil)
            
            print("user denied your app access to Location Services, but can grant access from Settings.app")
            break
        }
    }
    
    // MARK: - IBActions
    @IBAction func currentLocationPressed(_ sender: Any) {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.userLocation.coordinate
        
        if mapView.annotations.count > 0 {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        selectedLocation["lat"] = annotation.coordinate.latitude.description
        selectedLocation["lon"] = annotation.coordinate.longitude.description
        
        mapView.addAnnotation(annotation)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        backButtonPressed(sender)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if self.selectedLocation.count > 0 {
            NotificationCenter.default.post(name: CreateQuestViewController.notificationName, object: nil, userInfo:self.selectedLocation)
        }
        self.dismiss(animated: false, completion: nil)
    }
}
