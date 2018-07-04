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

public typealias BananoQuestListHandler = (_: [Quest]?, _: Error?) -> Void
public typealias NewBananoQuestHandler = (_: Quest?, _: Error?) -> Void
public typealias BananoQuestCompletionHandler = (_: QueryResponse?, _: Error?) -> Void

public class BananoQuest {
    private var mainContext: NSManagedObjectContext {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            }
            return appDelegate.persistentContainer.viewContext
        }
    }

    public func getLocalQuestList() -> [Quest] {
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
    
    public func createQuest(obj: [AnyHashable: Any], handler: @escaping NewBananoQuestHandler) {
        let quest = Quest(obj: obj, context: mainContext)
        
        // New Quest submitted
        do {
            try Networking.uploadNewQuest(quest: quest) { (newQuest, error) in
                if error != nil {
                    handler(nil,error)
                }else{
                    // Quest is saved in CoreData
                    newQuest?.save()
                    handler(newQuest,nil)
                }
            }
        } catch let error as NSError {
            handler(nil,error)
        }

    }
    
    public func completeQuest(quest: Quest, locations: [AnyHashable: Any], handler: @escaping BananoQuestCompletionHandler) {
        // Quest completion submitted
        do {
            try Networking.uploadQuestCompletion(quest: quest, locations: locations) { (response, error) in
                if error != nil {
                    handler(nil,error)
                }else{
                    handler(response,nil)
                }
            }
        } catch let error as NSError {
            handler(nil,error)
        }
        
    }
    
    public func createWallet(dict: [AnyHashable : Any]) throws -> Wallet {
        var wallet = Wallet.init(address: "", privateKey: "", network: "", data: [AnyHashable : Any]())
        
        do {
            wallet = try PocketEth.createWallet(data: dict)
            return wallet
        } catch let error as NSError {
            throw error
        }

    }
}
