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
        refreshView()
    }
    
    func refreshView() {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.quests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestCell", for: indexPath) as! QuestCollectionViewCell
        let quest = quests[indexPath.item]
        cell.configureCell(quest: quest, playerLocation: nil)
        return cell
    }
    
    func loadPlayerCompletedQuests() {
        // Initial load for the local quest list
        do {
            self.quests = try Quest.sortedQuestsByIndex(context: CoreDataUtil.mainPersistentContext)
            if self.quests.count == 0 {
                DispatchQueue.main.async {
                    //self.showElements(bool: true)
                    let label = self.showLabelWith(message: "No Quests available, please try again later...")
                    self.view.addSubview(label)
                }
            }else {
                //self.showElements(bool: false)
                self.refreshView()
            }
            print("quests found")
        } catch {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve quest list with error: \(error)")
        }
    }

}
