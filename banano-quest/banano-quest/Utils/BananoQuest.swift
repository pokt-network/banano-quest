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
    
    public static func createWallet(dict: [AnyHashable : Any]) throws -> Wallet {
        var wallet = Wallet.init(address: "", privateKey: "", network: "", data: [AnyHashable : Any]())
        
        wallet = try PocketEth.createWallet(data: dict)
        return wallet
    }
}
