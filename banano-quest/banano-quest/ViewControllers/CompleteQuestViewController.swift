//
//  CompleteQuestViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftHEXColors

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
    
    // MARK: View
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
            let alertView = self.bananoAlertView(title: "Error", message: "Location services are disabled, please enable before trying again.")
            self.present(alertView, animated: false, completion: nil)
            print("Location services are disabled, please enable before trying again.")
        }
        
        // Refresh view
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    func refreshView() throws {
        // Details view
        let maxWinnersDouble = Double(quest?.maxWinners ?? 1)
        let prizeValue = quest?.prize ?? 0.0 / maxWinnersDouble
        let bananoColor = UIColor(hexString: quest?.hexColor ?? "31AADE")
        
        bananoBackground.backgroundColor = bananoColor
        prizeValueLabel.text = "\(prizeValue) ETH"
        bananoCountLabel.text = "0/\(quest?.maxWinners ?? 1)"
        // TODO: Get location from merkleRoot
        distanceValueLabel.text = "20M"
        questDetailTextView.text = quest?.hint
    }
    
    // MARK: LocationManager
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
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func checkIfNearBanano(passphrase: String) {
        guard let merkle = QuestMerkleTree.generateQuestProofSubmission(answer: currentUserLocation!, merkleBody: (quest?.merkleBody)!) else {
            return
        }
        
        let questProof = QuestProofSubmission.init(answer: merkle.answer, proof: merkle.proof)
        do {
            let player = try Player.getPlayer(context: BaseUtil.mainContext)
            let wallet = try player.getWallet(passphrase: passphrase)
            
            let operation = UploadQuestProofOperation.init(wallet: wallet!, transactionCount: player.transactionCount, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questIndex: (quest?.index)!, proof: questProof.proof, answer: questProof.answer)
            
            operation.completionBlock = {
                
            }
            // Operation Queue
            let operationQueue = AsynchronousOperation.init()
            
            operationQueue.addDependency(operation)
            
            let alertView = bananoAlertView(title: "Submitted", message: "Proof submitted, your request is being processed in the background")
            
            self.present(alertView, animated: false, completion: nil)
            
        } catch let error as NSError {
            print("Failed to get player with error: \(error)")
        }
        
    }
    
    // TODO: Submit merkle proof before proceeding
    @IBAction func completeButtonPressed(_ sender: Any) {
        if currentUserLocation == nil {
            let alertController = bananoAlertView(title: "Wait", message: "Let the app get your current location :D")
            
            present(alertController, animated: false, completion: nil)
        }
        let alertView = requestPassphraseAlertView { (passphrase, error) in
            if passphrase != nil {
               self.checkIfNearBanano(passphrase: passphrase ?? "")
            }
            if error != nil {
                print("Failed to get passphrase with error: \(String(describing: error))")
            }
            
        }
        present(alertView, animated: false, completion: nil)
        
        return
        // TODO: Move findBananoViewController to a separate method
//        do {
//            let vc = try instantiateViewController(identifier: "findBananoViewControllerID", storyboardName: "Questing") as? FindBananoViewController
//            vc?.currentQuest = quest
//            vc?.currentUserLocation = currentUserLocation
//
//            present(vc!, animated: false, completion: nil)
//        } catch let error as NSError {
//            print("Failed to instantiate FindBananoViewController with error: \(error)")
//        }
    }
    
}
