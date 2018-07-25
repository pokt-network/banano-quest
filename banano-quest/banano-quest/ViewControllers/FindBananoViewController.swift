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
    @IBOutlet weak var claimButton: UIButton!

    fileprivate var arViewController: ARViewController!
    var bananoLocation: CLLocation?
    var currentUserLocation: CLLocation?
    var currentQuest: Quest?
    var questProof: QuestProofSubmission?

    override func viewDidLoad() {
        super.viewDidLoad()

        // AR Setup
        self.dataSource = self
        self.maxVisibleAnnotations = 5
        self.headingSmoothingFactor = 0.05

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }

<<<<<<< HEAD
    override func refreshView() throws {
=======
    func refreshView() throws {
>>>>>>> 79edc6f... Added proof logic, added submit proof operation, added BananoQuestViewController protocol
        // Banano Location is generated based in the user location after is confirmed the user is withing the quest
        // completion range.
        let coordinates = getBananoLocation()
        bananoLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        let questLocation = CLLocation(latitude: bananoLocation?.coordinate.latitude ?? 0.0, longitude: bananoLocation?.coordinate.longitude ?? 0.0)
        let bananoLocationC = CLLocation(coordinate: questLocation.coordinate, altitude: CLLocationDistance.init(currentUserLocation?.altitude ?? 0), horizontalAccuracy: CLLocationAccuracy.init(0), verticalAccuracy: CLLocationAccuracy.init(0), timestamp: Date.init())

        let distance = bananoLocationC.distance(from: currentUserLocation!)

        if distance <= 50 {
            let annotation = ARAnnotation()
            annotation.title = currentQuest?.name
            annotation.location = bananoLocationC

            // AR options
            // Max distance between the player and the Banano
            maxDistance = 50

            // We add the annotations that for Banano quest is 1 at a time
            setAnnotations([annotation])

        }else {
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
    // MARK: Tools
    func claimFailedAlertView() {
        let alertView = bananoAlertView(title: "Error", message: "Something happened while submitting your information, please try again later.")

        present(alertView, animated: false, completion: nil)
    }

    func claimBanano(passphrase: String) {

        do {
            let player = try Player.getPlayer(context: BaseUtil.mainContext)
            let wallet = try player.getWallet(passphrase: passphrase)

            guard let questIndex = Int64(currentQuest?.index ?? "0") else {
                claimFailedAlertView()
                return
            }

            guard let transactionCount = Int64(player.transactionCount) else {
                claimFailedAlertView()
                return
            }

            guard let proof = questProof?.proof else {
                claimFailedAlertView()
                return
            }

            guard let answer = questProof?.answer else {
                claimFailedAlertView()
                return
            }

            let operation = UploadQuestProofOperation.init(wallet: wallet!, transactionCount: transactionCount, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questIndex: questIndex, proof: proof, answer: answer)

            operation.completionBlock = {
                self.showNotificationOverlayWith(text: "CLAIM COMPLETED, check your new banano in your profile!")
            }

            // Operation Queue
            let operationQueue = AsynchronousOperation.init()

            operationQueue.addDependency(operation)

            let alertView = bananoAlertView(title: "Submitted", message: "Proof submitted, your request is being processed in the background")

            self.present(alertView, animated: false, completion: nil)

        } catch let error as NSError {
            print("Failed with error: \(error)")
        }
    }

    @IBAction func claimButtonPressed(_ sender: Any) {
        // Claim
        let alertView = requestPassphraseAlertView { (passphrase, error) in
            if passphrase != nil {
                self.claimBanano(passphrase: passphrase! )
            }
            if error != nil {
                let alertController = self.bananoAlertView(title: "ups!", message: "We failed to get that, please try again")

                self.present(alertController, animated: false, completion: nil)
            }
        }
        present(alertView, animated: false, completion: nil)

    }
}
