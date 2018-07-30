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
    @IBOutlet weak var addBalanceButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initial UI setup
        addBalanceButton.isEnabled = false
        continueButton.isEnabled = false
        
        createButton.setTitleColor(UIColor.darkGray, for: UIControlState.disabled)
        createButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapOutside)
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    // MARK: - Tools
    override func refreshView() throws {
        //
    }
    
    // MARK: - Actions
    @IBAction func copyAddressBtnPressed(_ sender: Any) {
        if !(addressLabel.text ?? "").isEmpty {
            UIPasteboard.general.string = addressLabel.text
        }else {
            print("Address label is empty, nothing to copy")
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
        
        createButton.isEnabled = false
        // Create the player
        do {
            let player = try Player.createPlayer(walletPassphrase: passphrase)
            self.addressLabel.text = player.address
            self.present(self.bananoAlertView(title: "Success", message: "Account created succesfully"), animated: true, completion: nil)
            continueButton.isEnabled = true
            addBalanceButton.isEnabled = true
            if let playerAddress = player.address {
                let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.bananoTokenAddress)
                appInitQueueDispatcher.initDisplatchSequence {
                    let questListQueueDispatcher = AllQuestsQueueDispatcher.init(tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.bananoTokenAddress, playerAddress: playerAddress)
                    questListQueueDispatcher.initDisplatchSequence(completionHandler: {
                        
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
        } catch let error as NSError {
            print("Failed to create wallet with error: \(error)")
            self.present(self.bananoAlertView(title: "Error", message: "Error creating your account, please try again"), animated: true, completion: nil)
        }
        createButton.isEnabled = true
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        do {
            let vc = try self.instantiateViewController(identifier: "ContainerVC", storyboardName: "Questing") as? ContainerViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
    }
}
