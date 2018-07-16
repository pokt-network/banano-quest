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

class NewWalletViewController: UIViewController {
    @IBOutlet weak var passphraseTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addBalanceButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Initial setup
        addBalanceButton.isEnabled = false
        continueButton.isEnabled = false
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
        guard let passphrase = passphraseTextField.text else { return  }
        
        do {
            let wallet = try PocketEth.createWallet(data: nil)
            if try wallet.save(passphrase: passphrase) {
                continueButton.isEnabled = true
                addBalanceButton.isEnabled = true
                
                addressLabel.text = wallet.address
                print("Wallet saved successfully with address: \(wallet.address) and privateKey: \(wallet.privateKey)")
            }else {
                print("Failed to save wallet")
            }
        } catch let error as NSError {
            print("Failed to create wallet with error: \(error)")
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        do {
            let vc = try self.instantiateViewController(identifier: "QuestingVC", storyboardName: "Questing") as? QuestingViewController
            
            self.navigationController?.pushViewController(vc!, animated: true)
            
        } catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
    }

}
