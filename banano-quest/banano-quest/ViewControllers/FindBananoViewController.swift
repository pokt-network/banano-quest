//
//  FindBananoViewController.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/24/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import MapKit

class FindBananoViewController: ARViewController, ARDataSource, AnnotationViewDelegate {
    fileprivate var arViewController: ARViewController!
    var bananoLocation: CLLocation?
    var currentUserLocation: CLLocation?
    var currentQuest: Quest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AR Setup
        self.dataSource = self
        self.maxVisibleAnnotations = 1
        self.headingSmoothingFactor = 0.05

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
    }
    
    func refreshView() {
        // Banano Location
        let coordinates = getBananoLocation()
        bananoLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        let questLocation = CLLocation(latitude: bananoLocation?.coordinate.latitude ?? 0.0, longitude: bananoLocation?.coordinate.longitude ?? 0.0)
        let bananoLocationC = CLLocation(coordinate: questLocation.coordinate, altitude: CLLocationDistance.init(40), horizontalAccuracy: CLLocationAccuracy.init(0), verticalAccuracy: CLLocationAccuracy.init(0), timestamp: Date.init())
        let distance = bananoLocationC.distance(from: currentUserLocation!)
        
        print("Distance between quest and player \(distance)")
        print("Quest altitude: \(bananoLocationC.altitude)")
        print("Player altitude: \(currentUserLocation?.altitude ?? 0.0)")
        print("Quest latitude:\(bananoLocationC.coordinate.latitude), longitude:\(bananoLocationC.coordinate.longitude)")
        print("Player latitude:\(currentUserLocation?.coordinate.latitude ?? 0.0), longitude:\(currentUserLocation?.coordinate.longitude ?? 0.0)")
        
        if distance <= 50 {
            let annotation = ARAnnotation()
            annotation.title = currentQuest?.name
            annotation.location = bananoLocationC
            
            // AR options, debugging options should be used only for testing
            //addDebugUi()
            //uiOptions.debugEnabled = true
            maxDistance = 50
            
            // We add the annotations that for Banano quest is 1 at a time
            setAnnotations([annotation])
            
        }else{
            let alertController = bananoAlertView(title: "Not in range", message: "\(currentQuest?.name ?? "") banano is not within 50 meters of your current location")
            
            present(alertController, animated: false, completion: nil)
        }
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func getBananoLocation() -> CLLocationCoordinate2D {
        if currentUserLocation == nil {
            return CLLocationCoordinate2D.init()
        }
        return locationWithBearing(bearing: 0.0, distanceMeters: 30, origin: (currentUserLocation?.coordinate)!)
    }
    
    func didTouch(annotationView: AnnotationView) {
        print("Touched the banano")
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        // View for the annotation setup
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        
        return annotationView
    }
    
}
