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
import BigInt

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
    @IBOutlet weak var questNameLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
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

    override func refreshView() throws {
        // Details view
        let maxWinnersDouble = Double.init(quest?.maxWinners ?? "0.0")
        
        if maxWinnersDouble != 0.0 {
            let weiAmount = BigInt.init(quest?.prize ?? "0") ?? BigInt.init(0)
            let prizeValue = EthUtils.convertWeiToEth(wei: weiAmount) / maxWinnersDouble!
            prizeValueLabel.text = "\(prizeValue) ETH"
        } else {
            prizeValueLabel.text = "NA"
        }
        
        if isQuestCreator() {
            completeButton.isEnabled = false
        } else {
            completeButton.isEnabled = true
        }

        let bananoColor = UIColor(hexString: quest?.hexColor ?? "31AADE")
        bananoBackground.backgroundColor = bananoColor
        //bananoCountLabel.text = "0/\(quest?.maxWinners ?? 1)"
        // TODO: Get location from merkleRoot
        distanceValueLabel.text = "20M"
        questDetailTextView.text = quest?.hint
        questNameLabel.text = quest?.name
    }
    
    // MARK: Tools
    // Is player the quest creator?
    func isQuestCreator() -> Bool {
        do {
            let player = try Player.getPlayer(context: BaseUtil.mainContext)
            if quest?.creator == player.address {
                return true
            }
        } catch let error as NSError {
            print("CompleteQuestViewController - isQuestCreator() - Failed to retrieve player information with error: \(error)")
        }
        return false
    }
    
    // Present Find Banano VC
    func presentFindBananoViewController(proof: QuestProofSubmission) {
        do {
            let vc = try instantiateViewController(identifier: "findBananoViewControllerID", storyboardName: "Questing") as? FindBananoViewController
            vc?.questProof = proof
            vc?.currentQuest = quest
            vc?.currentUserLocation = currentUserLocation
            
            present(vc!, animated: false, completion: nil)
        } catch let error as NSError {
            print("Failed to instantiate FindBananoViewController with error: \(error)")
        }
    }
    
    // Check if the user is near quest banano
    func checkIfNearBanano() {
        guard let merkle = QuestMerkleTree.generateQuestProofSubmission(answer: currentUserLocation!, merkleBody: (quest?.merkleBody)!) else {
            let alertView = bananoAlertView(title: "Not in range", message: "Sorry, the banano location isn't nearby")
            present(alertView, animated: false, completion: nil)
            
            return
        }
        // Show the Banano :D
        presentFindBananoViewController(proof: merkle)
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

    @IBAction func completeButtonPressed(_ sender: Any) {
        if currentUserLocation == nil {
            let alertController = bananoAlertView(title: "Wait!", message: "Let the app get your current location :D")

            present(alertController, animated: false, completion: nil)
            return
        }
        // Check if near banano location
        checkIfNearBanano()
    }
}
