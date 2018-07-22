//
//  Networking.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket

public typealias QuestListHandler = (_: Error?) -> Void
public typealias NewQuestHandler = (_: Quest?, _: Error?) -> Void
public typealias QuestCompletionHandler = (_: QueryResponse?, _: Error?) -> Void
public typealias QuestCountHandler = (_: Int32?, _: Error?) -> Void

public class Networking {
//    static let nodeURL = URL.init(string: "https://node.url")
//    
//    public static func getQuestList(handler: @escaping QuestListHandler) throws {
//        var params = [AnyHashable : Any]()
//        
//        // Retrieve Quests count
//        try getQuestListCount(handler: { (count, error) in
//            if error != nil {
//                print("\(String(describing: error))")
//            }
//            
//            var index = count ?? 0 - 1
//            // Create and execute a Query for each Quest from most recent to older
//            while index >= 0 {
//                params["_tokenAddress"] = "tokenaddress"
//                params["_questIndex"] = index
//                params["rpcMethod"] = "rpc_method_value"
//                params["rpcParams"] = "rpc_params_value" as Any
//                
//                do {
//                    let query = try createQuery(params: params)
//                    // Query execution to retrieve a single quest
//                    Pocket.shared.executeQuery(query: query, handler: { (response, error) in
//                        if error != nil {
//                            print("Failed to get Pocket instance for getQuestList() with error:\(String(describing: error))")
//                        }else{
//                            do{
//                                // Quest parsing
//                                let quest = try QuestDownloadParsing.parseDownload(dict: response!)
//                                // Quest is saved into CoreData
//                                try quest.save()
//                            }catch let error as NSError{
//                                handler(error)
//                            }
//                        }
//                    })
//                } catch let error as NSError{
//                    handler(error)
//                }
//                index = index - 1
//            }
//            // Completion handler
//            handler(nil)
//        })
//    }
//    
//    public static func getQuestListCount(handler: @escaping QuestCountHandler) throws {
//        // getQuestAmount(address _tokenAddress) returns (uint)
//        var params = [AnyHashable: Any]()
//        var questAmount = Int32(0)
//        
//        params["rpcMethod"] = "rpc_method_value"
//        params["rpcParams"] = [Any]()
//        
//        // Create and execute a Query to retrieve quest list count
//        let query = try createQuery(params: params)
//        
//        Pocket.shared.executeQuery(query: query, handler: { (response, error) in
//            if error != nil {
//                handler(nil, error)
//            }else {
//                //questAmount = response?.result!["length"] as? Int32 ?? 0
//                handler(questAmount, nil)
//            }
//        })
//    }
//    
//    public static func createQuery(params: [AnyHashable : Any]) throws -> Query {
//        let decoder = [AnyHashable: Any]()
//        let query = try PocketEth.createQuery(params: params, decoder: decoder)
//        
//        return query
//    }
//    
//    public static func uploadNewQuest(quest: Quest, handler: @escaping NewQuestHandler) throws{
//        let params = [AnyHashable : Any]()
//        
//            let query = try createQuery(params: params)
//            
//            Pocket.shared.executeQuery(query: query, handler: { (response, error) in
//                if error == nil {
//                    do{
//                        let parsedQuest = try QuestDownloadParsing.parseDownload(dict: response!)
//                        handler(parsedQuest, nil)
//                    }catch let error as NSError {
//                        handler(nil, error)
//                    }
//                }else{
//                    handler(nil, error)
//                }
//            })
//    }
//    
//    public static func uploadQuestCompletion(quest: Quest, locations: [AnyHashable: Any], handler: @escaping QuestCompletionHandler) throws {
//        let params = [AnyHashable : Any]()
//        
//            let query = try createQuery(params: params)
//            
//            Pocket.shared.executeQuery(query: query, handler: { (response, error) in
//                if error == nil {
//                    handler(response, nil)
//                }else{
//                    handler(nil, error)
//                }
//            })
//    }
}
