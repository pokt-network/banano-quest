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
    static let nodeURL = URL.init(string: "https://node.url")
    
    public static func getQuestList(handler: @escaping QuestListHandler) {
        var params = [AnyHashable : Any]()
        // Retrieve Quests count
        getQuestListCount(handler: { (count, error) in
            if error != nil {
                print("\(String(describing: error))")
            }
            
            var index = count ?? 0 - 1
            // Create and execute a Query for each Quest from most recent to older
            while index >= 0 {
                params["_tokenAddress"] = "tokenaddress"
                params["_questIndex"] = index
                
                do {
                    let query = try createQuery(with: params)
                    // Query execution to retrieve a single quest
                    Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                        if error != nil {
                            print("Failed to get Pocket instance for getQuestList() with error:\(String(describing: error))")
                        }else{
                            // Quest parsing
                            let quest = QuestDownloadParsing.parseDownload(dict: response!)
                            // Quest is saved into CoreData
                            quest.save()
                        }
                    })
                } catch let error as NSError{
                    handler(error)
                }
                index = index - 1
            }
            // Completion handler
            handler(nil)
        })
    }
    
    public static func getQuestListCount(handler: @escaping QuestCountHandler) {
        // getQuestAmount(address _tokenAddress) returns (uint)
        var params = [AnyHashable : Any]()
        var questAmount = Int32(0)
        
        params["_tokenAddress"] = "tokenaddress"
        
        do {
            // Create and execute a Query to retrieve quest list count
            let query = try createQuery(with: params)
            
            Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                if error != nil {
                    handler(nil, error)
                    print("Failed to get Pocket Instance for getQuestListCount() with error:\(String(describing: error))")
                }else{
                    questAmount = response?.result!["length"] as? Int32 ?? 0
                    handler(questAmount, nil)
                }
            })
        } catch let error as NSError{
            handler(nil,error)
        }
        
    }
    
    static func createQuery(with params: [AnyHashable : Any]) throws -> Query {
        var query = Query()
        
        do {
            query = try PocketEth.createQuery(params: [AnyHashable : Any](), decoder: [AnyHashable : Any]())
        } catch let error as NSError{
            throw error
        }
        
        return query
    }
    
    public static func uploadNewQuest(quest: Quest, handler: @escaping NewQuestHandler) throws{
        let params = [AnyHashable : Any]()
        
        do {
            let query = try createQuery(with: params)
            
            Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                if error == nil {
                    let parsedQuest = QuestDownloadParsing.parseDownload(dict: response!)
                    handler(parsedQuest, nil)
                }else{
                    handler(nil, error)
                }
            })
        } catch let error as NSError{
            throw error
        }
    }
    
    public static func uploadQuestCompletion(quest: Quest, locations: [AnyHashable: Any], handler: @escaping QuestCompletionHandler) throws {
        let params = [AnyHashable : Any]()
        
        do {
            let query = try createQuery(with: params)
            
            Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                if error == nil {
                    handler(response, nil)
                }else{
                    handler(nil, error)
                }
            })
        } catch let error as NSError{
            throw error
        }
    }
}
