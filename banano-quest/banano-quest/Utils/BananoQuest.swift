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
    public static var currentWallet: Wallet?
    // TODO: DELETE METHOD
    public static func createQuest(obj: [AnyHashable: Any], metadata: [AnyHashable: Any], handler: @escaping NewBananoQuestHandler) throws {
        //let quest = try Quest(obj: obj, metadata: metadata, context: BaseUtil.mainContext)
        
        // New Quest submitted
//        try Networking.uploadNewQuest(quest: quest) { (newQuest, error) in
//            if error != nil {
//                handler(nil,error)
//            }else{
//                // Quest is saved in CoreData
//                do{
//                    try newQuest?.save()
//                    handler(newQuest,nil)
//                }catch let error as NSError {
//                    handler(nil,error)
//                }
//            }
//        }
    }
    // TODO: DELETE METHOD
    public static func completeQuest(quest: Quest, locations: [AnyHashable: Any], handler: @escaping BananoQuestCompletionHandler) throws {
        // Quest completion submitted
//        try Networking.uploadQuestCompletion(quest: quest, locations: locations) { (response, error) in
//            if error != nil {
//                handler(nil,error)
//            }else{
//                handler(response,nil)
//            }
//        }
    }
    
    public static func createWallet(dict: [AnyHashable : Any]) throws -> Wallet {
        var wallet = Wallet.init(address: "", privateKey: "", network: "", data: [AnyHashable : Any]())
        
        wallet = try PocketEth.createWallet(data: dict)
        return wallet
    }
}
