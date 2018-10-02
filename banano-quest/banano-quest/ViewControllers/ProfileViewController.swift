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

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    var currentPlayer: Player?
    var quests: [Quest] = [Quest]()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
        loadPlayerCompletedQuests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func refreshView() throws {
        if currentPlayer == nil  {
            let alertView = bananoAlertView(title: "Error:", message: "Failed to retrieve current player, please try again later")
            present(alertView, animated: false, completion: nil)

            return
        }

        // Labels setup
        walletAddressLabel.text = currentPlayer?.address
        qrCodeImage.image = ProfileViewController.generateQRCode(from: currentPlayer?.address ?? "")
        if let weiBalanceStr = currentPlayer?.balanceWei {
            let weiBalance = BigInt.init(weiBalanceStr) ?? BigInt.init(0)
            let eth = String(format: "%.3f", arguments: [EthUtils.convertWeiToEth(wei: weiBalance)])
            let usd = String(format: "%.3f", arguments: [EthUtils.convertWeiToUSD(wei: weiBalance)])
            
            ethValueLabel.text = "\(eth) ETH"
            usdValueLabel.text = "\(usd) USD"
        }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
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

            let alertView = self.bananoAlertView(title: "WARNING", message: "Your private key has been copied to the clipboard, do not share it with anyone!: \(privateKey)", handler: { (UIAlertAction) in
                UIPasteboard.general.string = privateKey
            })
            
            self.present(alertView, animated: false, completion: nil)
        }) { (error) in
            print("\(error)")
            self.present(self.bananoAlertView(title: "Error", message: "Error retrieving your account details, please try again"), animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var yourWidth : CGFloat?
        var yourHeight : CGFloat?
        
        let device = UIDevice.modelName
        
        if device == "iPhone SE" || device == "Simulator iPhone SE" {
            yourWidth = collectionView.bounds.width/2.0
            yourHeight = yourWidth
        }else {
            yourWidth = collectionView.bounds.width/3.0
            yourHeight = yourWidth
        }
        return CGSize(width: yourWidth ?? 375, height: yourHeight ?? 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.quests.count == 0 {
            return 3
        } else {
            return self.quests.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if quests.count != 0  && indexPath.item < quests.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestCell", for: indexPath) as! QuestCollectionViewCell
            
            let quest = quests[indexPath.item]
            cell.quest = quest
            cell.configureCellFor(index: indexPath.item, playerLocation: nil)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerQuestCell", for: indexPath) as! QuestCollectionViewCell
            
            cell.configureEmptyCellFor(index: indexPath.item)
            
            return cell
        }
    }
    
    // MARK: Tools
    public static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func loadPlayerCompletedQuests() {
        // Initial load for the local quest list
        do {
            self.quests = try Quest.questsWonByPlayer(context: CoreDataUtils.mainPersistentContext)
            if self.quests.count != 0 {
                try self.refreshView()
            }
        } catch {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            print("Failed to retrieve quest list with error: \(error)")
        }
    }

}
