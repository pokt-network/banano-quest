//
//  LeaderboardViewController.swift
//  banano-quest
//
//  Created by MetaTedi on 9/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import BigInt

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var positionLabel: UILabel!
    
    var ownersRecords = [LeaderboardRecord]()
    var ownerPosition: Int?
    var currentPlayer: Player?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadAndSetLeaderboardData()
        positionLabel.text = ""
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to retrieve current player with error: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: UI
    func refreshTableView() {
        DispatchQueue.main.async() {
            self.tableView.reloadData()
        }
    }
    
    func setPositionLabelText() {
        if (ownerPosition == nil) {
            positionLabel.text = "Collect bananos to get ranked!"
        } else {
            positionLabel.text = "You are in position #\(ownerPosition!)!"
        }
    }
    
    // MARK: Data
    func calculateOwnerPosition() {
        for i in 0..<ownersRecords.count {
            let record = ownersRecords[i]
            let playerAddress = currentPlayer?.address
            if record.wallet == playerAddress {
                ownerPosition = i + 1
                break
            }
        }
    }
    
    func loadAndSetLeaderboardData() {
        activityIndicator.startAnimating()
        fetchOwnerCount(completionBlock: { count in
            if count == nil {
                return
            }
            self.ownersRecords = [LeaderboardRecord]()
            let dispatchGroup = DispatchGroup()
            for i in 0..<Int(count!){
                dispatchGroup.enter()
                self.fetchOwnerLeaderboardRecordCount(index: i, completionBlock: { (index, leaderboardRecord) in
                    if leaderboardRecord != nil {
                        self.ownersRecords.append(leaderboardRecord!)
                    }
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue:.main) {
                self.ownersRecords.sort(by: { (l1, l2) -> Bool in
                    return l1.tokenTotal! > l2.tokenTotal!
                })
                self.refreshTableView()
                self.calculateOwnerPosition()
                self.setPositionLabelText()
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func fetchOwnerCount(completionBlock:@escaping (BigInt?) -> Void) {
        let downloadOwnersCountOperation = DownloadOwnersCountOperation.init(bananoTokenAddress: AppConfiguration.bananoTokenAddress)
        downloadOwnersCountOperation.completionBlock = {
            guard let ownerTotal = downloadOwnersCountOperation.total else {
                print("Error fetching OwnersCount in Leaderboard")
                completionBlock(nil)
                return
                ///TODO: dismiss??
            }
            completionBlock(ownerTotal)
            print("Total owners in leadeboard:\(ownerTotal)")
        }
        downloadOwnersCountOperation.start()
    }
    
    func fetchOwnerLeaderboardRecordCount(index:Int,completionBlock:@escaping (Int,LeaderboardRecord?) -> Void) {
        let downloadOwnerTokenOperation = DownloadOwnersTokenCountOperation(bananoTokenAddress: AppConfiguration.bananoTokenAddress, ownerIndex: index)
        downloadOwnerTokenOperation.completionBlock = {
            guard let score = downloadOwnerTokenOperation.leaderboardRecord else {
                completionBlock(index,nil)
                return
            }
            completionBlock(index,score)
        }
        downloadOwnerTokenOperation.start()
    }
    
    // MARK: - IBActions
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ownersRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletScore") as! WalletScoreTableViewCell
        let score = ownersRecords[indexPath.row]
        let suffix = score.tokenTotal == 1 ? " banano":" bananos";
        cell.positionLabel.text = String(indexPath.row+1)
        cell.ethereumAddressLabel.text = score.wallet
        cell.bananosNumberLabel.text = score.tokenTotal != nil ? String(score.tokenTotal!) + suffix : ""
        return cell;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
