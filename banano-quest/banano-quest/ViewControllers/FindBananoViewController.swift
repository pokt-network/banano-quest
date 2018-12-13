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
import Pocket
import HDAugmentedReality

class FindBananoViewController: ARViewController, ARDataSource, AnnotationViewDelegate {
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var permissionsView: UIView!

    fileprivate var arViewController: ARViewController!
    var bananoLocation: CLLocation?
    var currentUserLocation: CLLocation?
    var currentQuest: Quest?
    var currentPlayer: Player?
    var questProof: QuestProofSubmission?
    
    // Activity Indicator
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var grayView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Current Player
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            self.present(self.bananoAlertView(title: "Error", message: "An error ocurred retrieving your account information, please try again"), animated: true)
            return
        }

        // AR Setup
        self.dataSource = self
        self.presenter.maxVisibleAnnotations = 1

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gray view setup
        grayView = UIView.init(frame: view.frame)
        grayView?.backgroundColor = UIColor.init(white: 1.0, alpha: 0.75)
        view.addSubview(grayView!)
        
        // Activity indicator setup
        indicator.center = view.center
        
        view.addSubview(indicator)
        indicator.startAnimating()
        
        self.view.isUserInteractionEnabled = false
        
        // Refresh player info
        refreshPlayerInfo()
    
    }

    override func refreshView() throws {
        // Check for camera permission
        checkCameraAccess()
    }

    func setupBananoAR() {
        // Banano Location is generated based in the user location after is confirmed the user is withing the quest
        // completion range.
        let coordinates = getBananoLocation()
        bananoLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        let questLocation = CLLocation(latitude: bananoLocation?.coordinate.latitude ?? 0.0, longitude: bananoLocation?.coordinate.longitude ?? 0.0)
        let bananoLocationC = CLLocation(coordinate: questLocation.coordinate, altitude: CLLocationDistance.init(currentUserLocation?.altitude ?? 0), horizontalAccuracy: CLLocationAccuracy.init(0), verticalAccuracy: CLLocationAccuracy.init(0), timestamp: Date.init())

        let distance = bananoLocationC.distance(from: currentUserLocation!)

        if distance <= 50 {
            let annotation = ARAnnotation.init(identifier: "quest", title: currentQuest?.name ?? "NONE", location: bananoLocationC)

            // AR options
            // Max distance between the player and the Banano
            self.presenter.maxDistance = 50

            // We add the annotations that for Banano quest is 1 at a time
            self.setAnnotations([annotation!])
        }else {
            let alertController = bananoAlertView(title: "Not in range", message: "\(currentQuest?.name ?? "") banano is not within 50 meters of your current location")
            present(alertController, animated: false, completion: nil)
        }
    }

    func checkCameraAccess() {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)

        if cameraIsAvailable {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .authorized:
                permissionsView.isHidden = true
                setupBananoAR()
            case .denied:
                permissionsView.isHidden = false

                let alertView = UIAlertController(title: "Camera Access", message: "Banano Quest is requesting camera access, will you like to enable access to the camera?", preferredStyle: .alert)

                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    self.openAppSettings()
                }))

                alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

                present(alertView, animated: false, completion: nil)

            case .notDetermined:
                requestCameraAccess()
            default:
                requestCameraAccess()
            }
        } else {
            let alertView = bananoAlertView(title: "Error", message: "Device has not cameras available")

            present(alertView, animated: false, completion: nil)
        }
    }

    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }

    }

    func requestCameraAccess() {
        let alertView = UIAlertController( title: "Camera Access", message: "Banano Quest would like to access your Camera to continue.", preferredStyle: .alert )

        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            if let _ = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                    DispatchQueue.main.async {
                        self.checkCameraAccess()
                    }
                }
            }else{
                let noCameraAlertView = self.bananoAlertView(title: "Failed", message: "Back Camera not available, please try again later.")
                self.present(noCameraAlertView, animated: false, completion: nil)
                print("Back Camera not available")
            }
        })

        alertView.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
            print("Permission denied")
        }
        alertView.addAction(declineAction)
        present(alertView, animated: true, completion: nil)
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
    func refreshPlayerInfo() {
        let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: currentPlayer?.address ?? "0", tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.bananoTokenAddress)
        appInitQueueDispatcher.initDispatchSequence {
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.indicator.stopAnimating()
                self.grayView?.isHidden = true
                
                do {
                    try self.refreshView()
                } catch let error as NSError {
                    print("Failed to refresh view with error: \(error)")
                }
            }
            
            print("Player information updated")
        }
    }
    
    func claimFailedAlertView() {
        let alertView = bananoAlertView(title: "Error", message: "Something happened while submitting your information, please try again later.")

        present(alertView, animated: false, completion: nil)
    }

    func claimBanano(wallet: Wallet) {

        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)

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
                    let claimOperation = UploadQuestProofOperation.init(wallet: wallet, transactionCount: transactionCount, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questIndex: questIndex, proof: proof, answer: answer)

                    claimOperation.completionBlock = {
                        if let txHash = claimOperation.txHash {
                            let transaction = Transaction.init(txHash: txHash, type: TransactionType.claim, context: CoreDataUtils.backgroundPersistentContext)
                            do {
                                try transaction.save()
                            } catch {
                                print("\(error)")
                            }
                        } else {
                            PushNotificationUtils.sendNotification(title: "BANANO Claim", body: "An error occurred claiming your BANANO for Quest \(questName), please try again.", identifier: "QuestClaimError")
                        }
                    }

                    operationQueue.addOperations([claimOperation], waitUntilFinished: false)
                } else {
                    self.showNotificationOverlayWith(text: "There was an error claiming your BANANO: \(questName)")
                }
            }

            // Operation Queue
            operationQueue.addOperations([nonceOperation], waitUntilFinished: false)
            let alertView = self.bananoAlertView(title: "Submitted", message: "Proof submitted, your request is being processed in the background") { (UIAlertAction) in
                
                self.backButtonPressed(self)
            }

            self.present(alertView, animated: false, completion: nil)

        } catch let error as NSError {
            print("Failed with error: \(error)")
        }
    }
    @IBAction func grantCameraAccess(_ sender: Any) {
        requestCameraAccess()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func claimButtonPressed(_ sender: Any) {
        self.retrieveGasEstimate { (gasEstimateWei) in
            if let gasEstimate = gasEstimateWei {
                // Transaction estimate
                let gasEstimateEth = EthUtils.convertWeiToEth(wei: gasEstimate)
                let gasEstimateUSD = EthUtils.convertEthAmountToUSD(ethAmount: gasEstimateEth)
                // Player balance
                let playerEthBalance = EthUtils.convertWeiToEth(wei: BigInt(self.currentPlayer?.balanceWei ?? "0")!)
                let playerUSDBalance = EthUtils.convertEthAmountToUSD(ethAmount: playerEthBalance)

                if gasEstimateUSD > playerUSDBalance {
                    let message = String.init(format: "Insufficient funds, Total transaction cost: %@ USD - %@ ETH. Current player balance: %@ USD - %@ ETH", String.init(format: "%.4f", gasEstimateUSD), String.init(format: "%.4f", gasEstimateEth), String.init(format: "%.4f", playerUSDBalance), String.init(format: "%.4f", playerEthBalance))
                    self.noBalanceHandler(message: message)

                    return
                }

                let message = String.init(format: "Total transaction cost: %@ USD - %@ ETH. Press OK to claim your Banano", String.init(format: "%.4f", gasEstimateUSD), String.init(format: "%.4f", gasEstimateEth))

                let txDetailsAlertView = self.bananoAlertView(title: "Transaction Details", message: message) { (uiAlertAction) in
                    do {
                        let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
                        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
                            self.claimBanano(wallet: wallet)
                        }, errorHandler: { (error) in
                            print("\(error)")
                            self.present(self.bananoAlertView(title: "Error", message: "An error ocurred retrieving your account information, please try again"), animated: true)
                        })
                    } catch {
                        self.present(self.bananoAlertView(title: "Error", message: "An error ocurred retrieving your account information, please try again"), animated: true)
                        return
                    }
                }
                self.present(txDetailsAlertView, animated: false, completion: nil)
            } else {
                let alertController = self.bananoAlertView(title: "Error", message: "Failed to calculate your transaction details and costs, please try again")
                self.present(alertController, animated: false, completion: nil)
                return
            }
        }
    }

    func noBalanceHandler(message: String) {
        let alertView = bananoAlertView(title: "Failed", message: message)
        let addBalance = UIAlertAction.init(title: "Add Balance", style: .default) { (UIAlertAction) in
            do {
                let vc = try self.instantiateViewController(identifier: "addBalanceViewControllerID", storyboardName: "Profile")
                self.present(vc, animated: false, completion: nil)
            }catch let error as NSError {
                print("Failed to instantiate addBalanceViewControllerID with error: \(error)")
            }
        }
        alertView.addAction(addBalance)
        present(alertView, animated: false, completion: nil)
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
