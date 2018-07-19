//
//  LandingViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import Pocket

class LandingViewController: UIViewController {
    var wallets = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Initial setup
        wallets = Wallet.retrieveWalletRecordKeys()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func playNowPressed(_ sender: Any) {
        if wallets.count == 0 {
            do {
                let vc = try self.instantiateViewController(identifier: "walletCreationViewControllerID", storyboardName: "Main") as? NewWalletViewController

                self.navigationController?.pushViewController(vc!, animated: false)
            }catch let error as NSError {
                print("Failed to instantiate NewWalletViewController with error: \(error)")
            }
        }else {
            do {
                let vc = try self.instantiateViewController(identifier: "ContainerVC", storyboardName: "Questing") as? ContainerViewController
                
                var wallet: Wallet?
                
                let alertView = requestPassphraseAlertView { (passphrase, error) in
                    if error != nil {
                        print("Failed to retrieve passphrase from textfield.")
                    }else {
                        do {
                            wallet = try BananoQuest.getCurrentWallet(passphrase: passphrase ?? "")
                            BananoQuest.currentWallet = wallet
                            self.navigationController?.pushViewController(vc!, animated: false)
                        }catch let error as NSError {
                            print("Failed with error: \(error)")
                        }
                    }
                }
                
                present(alertView, animated: false, completion: nil)
            }catch let error as NSError {
                print("Failed to instantiate QuestingViewController with error: \(error)")
            }
        }
    }

}
