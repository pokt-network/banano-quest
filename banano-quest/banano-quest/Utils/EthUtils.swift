//
//  EthUtils.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData

public struct EthUtils {
    
    public static let unitaryEthToWeiQuotient = 1000000000000000000
    
    // Converts wei amount to usd amount
    public static func convertWeiToUSD(wei: Int64) -> Double {
        return EthUtils.convertWeiToEth(wei: wei) * EthUtils.unitaryEthPriceUSD()
    }
    
    // Converts wei to eth amount
    public static func convertWeiToEth(wei: Int64) -> Double {
        return Double.init(wei)/Double(EthUtils.unitaryEthToWeiQuotient)
    }
    
    // Returns the price of a single eth in usd amount
    public static func unitaryEthPriceUSD() -> Double {
        var result = 0.0
        var player: Player?
        do {
            player = try Player.getPlayer(context: NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType))
        } catch {
            return result
        }
        
        guard let playerInstance = player else {
            return result
        }
        result = playerInstance.ethUsdPrice
        
        // refresh data if 0
        if result == 0.0 {
            guard let playerAddress = playerInstance.address else {
                return result
            }
            AppInitQueueDispatcher.init(playerAddress: playerAddress, tavernAddress: AppConfiguration.tavernAddress, bananoTokenAddress: AppConfiguration.tavernAddress).initDisplatchSequence(completionHandler: nil)
        }
        
        return result
    }
    
    public static func convertEthToWei(eth: Double) -> Int64 {
        return Int64(eth * Double(EthUtils.unitaryEthToWeiQuotient))
    }
    
}
