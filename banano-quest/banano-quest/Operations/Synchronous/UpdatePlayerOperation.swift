//
//  UpdateTavernQuestAmount.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData
import BigInt

public class UpdatePlayerOperation: SynchronousOperation {
    
    private var balanceWei: BigInt?
    private var transactionCount: BigInt?
    private var questAmount: BigInt?
    private var ethUsdPrice: Double?
    
    public init(balanceWei: BigInt?, transactionCount: BigInt?, questAmount: BigInt?, ethUsdPrice: Double?) {
        self.balanceWei = balanceWei
        self.transactionCount = transactionCount
        self.questAmount = questAmount
        self.ethUsdPrice = ethUsdPrice
        super.init()
    }
    
    open override func main() {
        do {
            let context = CoreDataUtil.backgroundPersistentContext
            context.performAndWait {
                do {
                    let player = try Player.getPlayer(context: context)
                    if let balanceWei = self.balanceWei {
                        player.balanceWei = String.init(balanceWei)
                    }
                    
                    if let transactionCount = self.transactionCount {
                        player.transactionCount = String.init(transactionCount)
                    }
                    
                    if let questAmount = self.questAmount {
                        player.tavernQuestAmount = String.init(questAmount)
                    }
                    
                    if let ethUsdPrice = self.ethUsdPrice {
                        player.ethUsdPrice = ethUsdPrice
                    }
                    
                    // Save updated player
                    try player.save()
                } catch {
                    print("Error performing UpdatePlayerOperation")
                }
            }
        } catch {
            self.error = error
        }
    }
}
