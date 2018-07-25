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

class ProfileViewController: UIViewController {
    @IBOutlet weak var walletAddressLabel: UILabel!
    @IBOutlet weak var usdValueLabel: UILabel!
    @IBOutlet weak var ethValueLabel: UILabel!
    
    var currentPlayer: Player?
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            currentPlayer = try Player.getPlayer(context: BaseUtil.mainContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }

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
            ethValueLabel.text = "\(EthUtils.convertWeiToEth(wei: weiBalance))"
            usdValueLabel.text = "\(EthUtils.convertWeiToUSD(wei: weiBalance))"
        }
    }
    
    // MARK: - IBActions
    @IBAction func copyAddressButtonPressed(_ sender: Any) {
        if walletAddressLabel.text?.isEmpty ?? true {
            let alertView = bananoAlertView(title: "Error:", message: "Address field is empty, please try again later")
            present(alertView, animated: false, completion: nil)
            
            return
        }
        
        UIPasteboard.general.string = walletAddressLabel.text
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }

}
