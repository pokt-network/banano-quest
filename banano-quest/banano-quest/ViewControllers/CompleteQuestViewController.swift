//
//  CompleteQuestViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CompleteQuestViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bananoBackground: UIView!
    @IBOutlet weak var numberOfBananosLabel: UILabel!
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var prizeValueLabel: UILabel!
    @IBOutlet weak var bananoCountLabel: UILabel!
    @IBOutlet weak var questDetailTextView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentUserLocation: CLLocation?
    var quest: Quest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Map settings
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        // Location Manager settings
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Background settings
        bananoBackground.layer.cornerRadius = bananoBackground.frame.size.width / 2
        bananoBackground.clipsToBounds = true
        
        // Checks is location services are enabled to start updating location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }else{
            print("Location services are disabled, please enable before trying again.")
        }
        
        // Refresh view
        refreshView()
    }
    
    func refreshView() {
        // Details view
        bananoCountLabel.text = "0/\(quest?.maxWinners ?? 1)"
        prizeValueLabel.text = "\(quest?.prize ?? 1).0 USD"
        // TODO: Get location from merkleRoot
        distanceValueLabel.text = "20M"
        questDetailTextView.text = quest?.hint
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update
        if locations.count > 0 {
            let location = locations.last!
            
            currentUserLocation = location
            
            print("Accuracy: \(location.horizontalAccuracy)")
            if location.horizontalAccuracy < 100 {
                
                manager.stopUpdatingLocation()
                // span: is how much it should zoom into the user location
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                // updates map with current user location
                mapView.region = region
                
            }else{
                print("Location accuracy is not under 100 meters, skipping...")
            }
        }else{
            print("Failed to get current location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // TODO: Update authorize/denied location access flow
        }
    }
    @IBAction func completeButtonPressed(_ sender: Any) {
    }
    
}
