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
    
    // Refresh Control
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = UIColor(red: (252/255), green: (216/255), blue: (50/255), alpha: 1)
        refreshControl.transform = CGAffineTransform(scaleX: 1.75, y: 1.75)
        return refreshControl
    }()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getPlayer()
        loadPlayerCompletedQuests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView?.contentSize = CGSize.init(width: (scrollView?.contentSize.width)!, height: 1000.0)
        scrollView.addSubview(refreshControl)
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }

    override func refreshView() throws {
        if currentPlayer == nil  {
            let alertView = bananoAlertView(title: "Error:", message: "Failed to retrieve current player, please try again later")
            present(alertView, animated: false, completion: nil)
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            
            return
        }

        // Labels setup
        walletAddressLabel.text = currentPlayer?.address
        if let weiBalanceStr = currentPlayer?.balanceWei {
            let weiBalance = BigInt.init(weiBalanceStr) ?? BigInt.init(0)
            ethValueLabel.text = "\(EthUtils.convertWeiToEth(wei: weiBalance)) ETH"
            usdValueLabel.text = "\(EthUtils.convertWeiToUSD(wei: weiBalance)) USD"
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - IBActions
    @IBAction func copyAddressButtonPressed(_ sender: Any) {
        let showError = {
            let alertView = self.bananoAlertView(title: "Error:", message: "Address field is empty, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
        guard let isAddressEmpty = walletAddressLabel.text?.isEmpty else {
            showError()
            return
        }
        if isAddressEmpty {
            showError()
            return
        } else {
            let alertView = bananoAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
            present(alertView, animated: false, completion: nil)
            UIPasteboard.general.string = walletAddressLabel.text
        }
    }

    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }

    @IBAction func exportPressed(_ sender: Any) {
        // Resolve wallet auth
        guard let player = currentPlayer else {
            self.present(self.bananoAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
            return
        }
        
        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
            let privateKey = wallet.privateKey
            let alertView = self.bananoAlertView(title: "WARNING", message: "This is your private key, do not share it with anyone!: " + privateKey)
            self.present(alertView, animated: false, completion: nil)
        }) { (error) in
            print("\(error)")
            self.present(self.bananoAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
        }
    }
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.quests.count == 0 {
            return 1
        } else {
            return self.quests.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if quests.count != 0  && indexPath.item < quests.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestCell", for: indexPath) as! QuestCollectionViewCell
            
            let quest = quests[indexPath.item]
            cell.quest = quest
            cell.configureCell(playerLocation: nil)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestEmptyCell", for: indexPath)
            return cell
        }
    }
    
    // MARK: Tools
    func loadPlayerCompletedQuests() {
        // Initial load for the local quest list
        do {
            self.quests = try Quest.questsWonByPlayer(context: CoreDataUtils.mainPersistentContext)
            if self.quests.count != 0 {
                try self.refreshView()
            }else {
                self.refreshControl.endRefreshing()
            }
        } catch {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            print("Failed to retrieve quest list with error: \(error)")
            refreshControl.endRefreshing()
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getPlayer()
        loadPlayerCompletedQuests()
    }
    
    func getPlayer() {
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
    }

}
