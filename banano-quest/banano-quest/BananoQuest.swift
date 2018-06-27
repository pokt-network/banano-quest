//
//  BananoQuest.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket
import CoreData

public class BananoQuest {
    private let mainContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    public func getQuestList() -> [Quest] {
        // Quests list retrieved from CoreData
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        do {
            quests = try mainContext.fetch(fetchRequest) as [Quest]
        } catch let error as NSError {
            print("Failed to fetch local Quests with error: \(error)")
        }
        
        return quests
    }
    
    public func createQuest(obj: [AnyHashable: Any]) -> Quest {
        // Quest is saved in CoreData
        let quest = Quest(obj: obj, context: mainContext)
        quest.save()
        
        // New Quest submitted
        if Networking.uploadNewQuest(quest: quest) {
            print("New quest submitted without errors")
        }else{
            print("Failed to submit new quest to the blockchain")
        }
        
        return quest
    }
    
    public func completeQuest(quest: Quest, locations: [AnyHashable: Any]) -> Bool {
        // Quest completion submitted
        return Networking.uploadQuestCompletion(quest: quest, locations: locations)
    }
    
    public func createWallet(dict: [AnyHashable : Any]) -> Wallet {
        var wallet = Wallet.init(address: "", privateKey: "", network: "", data: [AnyHashable : Any]())
        
        do {
            wallet = try PocketEth.createWallet(data: dict)
            return wallet
        } catch {
            print("")
        }
        
        return wallet
    }
    
    public func importWallet(privateKey: String, address: String, data: [AnyHashable : Any]) -> Wallet{
        var wallet = Wallet.init(address: "", privateKey: "", network: "", data: [AnyHashable : Any]())
    
        do {
            wallet = try PocketEth.importWallet(privateKey: privateKey, address: address, data: data)
            return wallet
        } catch {
            print("")
        }
        
        return wallet
    }
}
