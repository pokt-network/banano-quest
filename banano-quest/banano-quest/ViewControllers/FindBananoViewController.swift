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
import BigInt

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

    override func refreshView() throws {
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
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            let wallet = try player.getWallet(passphrase: passphrase)

            guard let questIndex = BigInt.init(currentQuest?.index ?? "0") else {
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
            guard let playerAddress = player.address else {
                claimFailedAlertView()
                return
            }
            guard let questName = currentQuest?.name else {
                claimFailedAlertView()
                return
            }

            let operationQueue = OperationQueue()
            let nonceOperation = DownloadTransactionCountOperation.init(address: playerAddress)
            nonceOperation.completionBlock = {
                if let transactionCount = nonceOperation.transactionCount {
                    let claimOperation = UploadQuestProofOperation.init(wallet: wallet!, transactionCount: transactionCount, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questIndex: questIndex, proof: proof, answer: answer)

                    claimOperation.completionBlock = {
                        if claimOperation.txHash != nil {
                            self.showNotificationOverlayWith(text: "CLAIM COMPLETED, check your \(questName) BANANO in your profile!")
                        } else {
                            self.showNotificationOverlayWith(text: "There was an error claiming your BANANO: \(questName)")
                        }
                    }

                    operationQueue.addOperations([claimOperation], waitUntilFinished: false)
                } else {
                    self.showNotificationOverlayWith(text: "There was an error claiming your BANANO: \(questName)")
                }
            }

            // Operation Queue
            operationQueue.addOperations([nonceOperation], waitUntilFinished: false)

            let alertView = bananoAlertView(title: "Submitted", message: "Proof submitted, your request is being processed in the background")

            self.present(alertView, animated: false, completion: nil)

        } catch let error as NSError {
            print("Failed with error: \(error)")
        }
    }

    @IBAction func claimButtonPressed(_ sender: Any) {
        self.retrieveGasEstimate { (gasEstimateWei) in
            if let gasEstimate = gasEstimateWei {
                let gasEstimateEth = EthUtils.convertWeiToEth(wei: gasEstimate)
                let gasEstimateUSD = EthUtils.convertEthAmountToUSD(ethAmount: gasEstimateEth)
                let message = String.init(format: "Total transaction cost: %@ USD - %@ ETH. Press OK to create your Quest", String.init(format: "%.4f", gasEstimateUSD), String.init(format: "%.4f", gasEstimateEth))
                
                let txDetailsAlertView = self.bananoAlertView(title: "Transaction Details", message: message) { (uiAlertAction) in
                    let alertView = self.requestPassphraseAlertView { (passphrase, error) in
                        if passphrase != nil {
                            self.claimBanano(passphrase: passphrase! )
                        }
                        if error != nil {
                            let alertController = self.bananoAlertView(title: "ups!", message: "We failed to get that, please try again")
                            self.present(alertController, animated: false, completion: nil)
                        }
                    }
                    self.present(alertView, animated: false, completion: nil)
                }
                self.present(txDetailsAlertView, animated: false, completion: nil)
            } else {
                let alertController = self.bananoAlertView(title: "Error", message: "Failed to calculate your transaction details and costs, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
        }
    }
    
    func retrieveGasEstimate(handler: @escaping (BigInt?) -> Void) {
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            guard let questIndexStr = currentQuest?.index else {
                let alertController = self.bananoAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            guard let proof = questProof?.proof else {
                let alertController = self.bananoAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            guard let answer = questProof?.answer else {
                let alertController = self.bananoAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
            let operationQueue = OperationQueue.init()
            let gasEstimateOperation = UploadQuestProofEstimateOperation.init(playerAddress: player.address!, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questIndex: BigInt.init(questIndexStr)!, proof: proof, answer: answer)
            gasEstimateOperation.completionBlock = {
                handler(gasEstimateOperation.estimatedGasWei)
            }
            operationQueue.addOperations([gasEstimateOperation], waitUntilFinished: false)
        } catch {
            let alertController = self.bananoAlertView(title: "Error", message: "Failed to retrieve your account data, please try again")
            self.present(alertController, animated: false, completion: nil)
            return
        }
    }
}
