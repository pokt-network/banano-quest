//
//  Player+CoreDataClass.swift
//  
//
//  Created by Luis De Leon on 7/19/18.
//
//

import Foundation
import CoreData
import Pocket

public enum PlayerPersistenceError: Error {
    case retrievalError
}

@objc(Player)
public class Player: NSManagedObject {
    
    convenience init(obj: [AnyHashable: Any]?, context: NSManagedObjectContext) throws {
        self.init(context: context)
        if let playerObj = obj {
            self.address = playerObj["address"] as? String ?? ""
            self.balanceWei = playerObj["balanceWei"] as? Int64 ?? 0
            self.transactionCount = playerObj["transactionCount"] as? Int64 ?? 0
            self.tavernQuestAmount = playerObj["tavernQuestAmount"] as? Int64 ?? 0
            self.ethUsdPrice = playerObj["ethUsdPrice"] as? Double ?? 0.0
        }
    }
    
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    // Either returns a new player to save data to, or returns the existing player
    public static func getPlayer(context: NSManagedObjectContext) throws -> Player {
        var result: Player
        let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
        let playerStore = try context.fetch(fetchRequest) as [Player]
        
        if playerStore.count > 0 {
            guard let player = playerStore.first else {
                throw PlayerPersistenceError.retrievalError
            }
            result = player
        } else {
            throw PlayerPersistenceError.retrievalError
        }
        return result
    }
    
    public func getWallet(passphrase: String) throws -> Wallet? {
        var result: Wallet?
        if let playerAddress = self.address {
            result = try Wallet.retrieveWallet(network: "ETH", address: playerAddress, passphrase: passphrase)
        }
        return result
    }
}
