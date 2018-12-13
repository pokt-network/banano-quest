//
//  NewWalletViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
//import Pocket
import PocketEth
import CoreData

class NewWalletViewController: UIViewController {
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var setupBiometricsButton: UIButton!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var addressLabelUnderline: UILabel!
    @IBOutlet weak var forwardIcon: UIImageView!
    
    var currentPlayer: Player?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    func toggleAfterCreateControls() {
        if BiometricsUtils.biometricsAvailable {
            setupBiometricsButton.isHidden = !setupBiometricsButton.isHidden
        } else {
            setupBiometricsButton.isHidden = true
        }
        copyAddressButton.isHidden = !copyAddressButton.isHidden
        addressLabel.isHidden = !addressLabel.isHidden
        addressLabelUnderline.isHidden = !addressLabelUnderline.isHidden
        continueButton.isHidden = !continueButton.isHidden
    }

    // MARK: - Tools
    override func refreshView() throws {
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
    }
    
    func startDataDownload(playerAddress: String) {
        let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.bananoTokenAddress)
        appInitQueueDispatcher.initDispatchSequence {
            let questListQueueDispatcher = AllQuestsQueueDispatcher.init(tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.bananoTokenAddress, playerAddress: playerAddress)
            questListQueueDispatcher.initDispatchSequence(completionHandler: {
                
                UIApplication.getPresentedViewController(handler: { (topVC) in
                    if topVC == nil {
                        print("Failed to get current view controller")
                    }else {
                        do {
                            try topVC!.refreshView()
                        }catch let error as NSError {
                            print("Failed to refresh current view controller with error: \(error)")
                        }
                    }
                })
            })
        }
    }
    
    func biometricsSetupSuccessHandler() {
        self.present(self.bananoAlertView(title: "Success!", message: "You have succesfully setup biometric authentication for your account."), animated: true, completion: nil)
        toggleBiometricsButton()
    }
    
    func biometricsSetupErrorHandler(error: Error) {
        self.present(self.bananoAlertView(title: "Error", message: "An error ocurred setting up biometric authentication for your account, please try again."), animated: true, completion: nil)
        toggleBiometricsButton()
    }
    
    func toggleBiometricsButton() {
        guard let player = currentPlayer else {
            return
        }
        
        guard let playerAddress = player.address else {
            return
        }
        
        // Only re-enable if it wasn't succesful
        if BiometricsUtils.biometricRecordExists(playerAddress: playerAddress) {
            self.setupBiometricsButton.isEnabled = false
            self.setupBiometricsButton.isHidden = true
        } else {
            self.setupBiometricsButton.isEnabled = true
            self.setupBiometricsButton.isHidden = false
        }
    }

    // MARK: - Actions
    @IBAction func copyAddressBtnPressed(_ sender: Any) {
        let showError = {
            let alertView = self.bananoAlertView(title: "Error:", message: "Address field is empty, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
        guard let isAddressEmpty = addressLabel.text?.isEmpty else {
            showError()
            return
        }
        if isAddressEmpty {
            showError()
            return
        } else {
            let alertView = bananoAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
            present(alertView, animated: false, completion: nil)
            UIPasteboard.general.string = addressLabel.text
        }
    }

    @IBAction func createWallet(_ sender: Any) {
        guard let passphrase = passphraseTextField.text else {
            let alertView = bananoAlertView(title: "Error", message: "Failed to get password, please try again later")
            present(alertView, animated: false, completion: nil)
            return
        }

        if passphrase.isEmpty {
            let alertView = bananoAlertView(title: "Invalid", message: "Password shouldn't be empty")
            present(alertView, animated: false, completion: nil)
            return
        }
        
        
        // Disable create button
        self.createButton.isEnabled = false
        
        // Create the player
        do {
            currentPlayer = try Player.createPlayer(walletPassphrase: passphrase)
            guard let player = currentPlayer else {
                self.present(self.bananoAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
                return
            }
            if let playerAddress = player.address {
                self.addressLabel.text = playerAddress
                self.present(self.bananoAlertView(title: "Success", message: "Account created succesfully"), animated: true, completion: nil)
                toggleAfterCreateControls()
                startDataDownload(playerAddress: playerAddress)
            } else {
                self.present(self.bananoAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
            }
        } catch {
            print("Failed to create wallet with error: \(error)")
            self.present(self.bananoAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
        }
        // End creating player
        
        // Only re-enable create button if player wasn't created succesfully
        if let _ = currentPlayer {
            self.createButton.isEnabled = false
            self.createButton.isHidden = true
            self.passphraseTextField.isHidden = true
        } else {
            self.createButton.isEnabled = true
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        guard let _ = currentPlayer else {
            self.present(self.bananoAlertView(title: "Error", message: "Please enter your passphrase and press Create"), animated: true, completion: nil)
            return
        }
        do {
            let vc = try self.instantiateViewController(identifier: "ContainerVC", storyboardName: "Questing") as? ContainerViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
    }
    
    @IBAction func biometricsSetupPressed(_ sender: Any) {
        guard let _ = currentPlayer else {
            self.present(self.bananoAlertView(title: "Error", message: "You need to create an account first"), animated: true, completion: nil)
            return
        }
        
        guard let passphrase = passphraseTextField.text else {
            let alertView = bananoAlertView(title: "Error", message: "Failed to get passphrase, please try again later")
            present(alertView, animated: false, completion: nil)
            return
        }
        
        if passphrase.isEmpty {
            let alertView = bananoAlertView(title: "Invalid", message: "Passphrase shouldn't be empty")
            present(alertView, animated: false, completion: nil)
            return
        }
        
        // Disable button
        self.setupBiometricsButton.isEnabled = false
        
        // Setup biometrics
        BiometricsUtils.setupPlayerBiometricRecord(passphrase: passphrase, successHandler: biometricsSetupSuccessHandler, errorHandler: biometricsSetupErrorHandler)
    }
}
