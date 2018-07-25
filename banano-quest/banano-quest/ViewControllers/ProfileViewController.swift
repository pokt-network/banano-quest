//
//  ProfileViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/18/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import PocketEth
import Pocket
import BigInt

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!

    var currentPlayer: Player?
    var quests: [Quest] = [Quest]()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            currentPlayer = try Player.getPlayer(context: BaseUtil.mainContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        loadPlayerCompletedQuests()
        scrollView?.contentSize = CGSize.init(width: (scrollView?.contentSize.width)!, height: 1000.0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }

    func refreshView() throws {
        if currentPlayer == nil  {
            let alertView = bananoAlertView(title: "Error:", message: "Failed to retrieve current player, please try again later")
            present(alertView, animated: false, completion: nil)

            return
        }

        // Labels setup
        walletAddressLabel.text = currentPlayer?.address
        if let weiBalanceStr = currentPlayer?.balanceWei {
            let weiBalance = BigInt.init(weiBalanceStr, radix: 16) ?? BigInt.init(0)
            ethValueLabel.text = "\(EthUtils.convertWeiToEth(wei: weiBalance)) ETH"
            usdValueLabel.text = "\(EthUtils.convertWeiToUSD(wei: weiBalance)) USD"
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: - IBActions
    @IBAction func copyAddressButtonPressed(_ sender: Any) {
        if walletAddressLabel.text?.isEmpty ?? true {
            let alertView = bananoAlertView(title: "Error:", message: "Address field is empty, please try again later")
            present(alertView, animated: false, completion: nil)

            return
        }

        let alertView = bananoAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
        present(alertView, animated: false, completion: nil)
        UIPasteboard.general.string = walletAddressLabel.text
    }

    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }

    @IBAction func exportPressed(_ sender: Any) {
        // Prompt passphrase input to unlock wallet
        let alertView = requestPassphraseAlertView { (passphrase, error) in
            if error != nil {
                // Show alertView for error if passphrase is nil
                let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve passphrase from textfield.")
                self.present(alertView, animated: false, completion: nil)
            }else {
                // Retrieve wallet with passphrase
                do {
                    let wallet = try self.currentPlayer?.getWallet(passphrase: passphrase ?? "")
                    if let privateKey = wallet?.privateKey {
                        let alertView = self.bananoAlertView(title: "WARNING", message: "This is your private key, do not share it with anyone!: " + privateKey)
                        self.present(alertView, animated: false, completion: nil)
                    } else {
                        let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve your wallet's private key, please try again.")
                        self.present(alertView, animated: false, completion: nil)
                    }
                }catch let error as NSError {
                    let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve account with passphrase, please try again later.")
                    self.present(alertView, animated: false, completion: nil)
                    print("Failed with error: \(error)")
                }
            }
        }
        self.present(alertView, animated: false, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.quests.count == 0 {
            return 1
        } else {
            return self.quests.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if quests.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestCell", for: indexPath) as! QuestCollectionViewCell
            let quest = quests[indexPath.item]
            cell.configureCell(quest: quest, playerLocation: nil)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestEmptyCell", for: indexPath)
            return cell
        }
    }

    func loadPlayerCompletedQuests() {
        // Initial load for the local quest list
        do {
            self.quests = try Quest.questsWonByPlayer(context: CoreDataUtil.mainPersistentContext)
            if self.quests.count != 0 {
                self.refreshView()
            }
        } catch {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            print("Failed to retrieve quest list with error: \(error)")
        }
    }

}
