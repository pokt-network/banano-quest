//
//  UpdateTavernQuestAmount.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData

public class UpdatePlayerOperation: SynchronousOperation {
    
    private var balanceWei: Int64?
    private var transactionCount: Int64?
    private var questAmount: Int64?
    private var ethUsdPrice: Double?
    
    public init(balanceWei: Int64?, transactionCount: Int64?, questAmount: Int64?, ethUsdPrice: Double?) {
        self.balanceWei = balanceWei
        self.transactionCount = transactionCount
        self.questAmount = questAmount
        self.ethUsdPrice = ethUsdPrice
        super.init()
    }
    
    open override func main() {
        do {
            let player = try Player.getPlayer(context: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType))
            
            if let balanceWei = self.balanceWei {
                player.balanceWei = balanceWei
            }
            
            if let transactionCount = self.transactionCount {
                player.transactionCount = transactionCount
            }
            
            if let questAmount = self.questAmount {
                player.tavernQuestAmount = questAmount
            }
            
            if let ethUsdPrice = self.ethUsdPrice {
                player.ethUsdPrice = ethUsdPrice
            }
            
            // Save updated player
            try player.save()
        } catch {
            self.error = error
        }
    }
}
