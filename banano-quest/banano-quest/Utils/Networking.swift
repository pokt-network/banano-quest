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

public typealias QuestListHandler = (_: [Quest]?, _: Error?) -> Void
public typealias NewQuestHandler = (_: Quest?, _: Error?) -> Void
public typealias QuestCompletionHandler = (_: QueryResponse?, _: Error?) -> Void
public typealias QuestCountHandler = (_: Int32?, _: Error?) -> Void

public class Networking {
    static let nodeURL = URL.init(string: "https://node.url")
    
    public static func getQuestList() {
        var params = [AnyHashable : Any]()
        
        getQuestListCount(handler: { (count, error) in
            if error != nil {
                print("\(String(describing: error))")
            }
            
            var index = count ?? 0 - 1
            
            while index >= 0 {
                params["_tokenAddress"] = "tokenaddress"
                params["_questIndex"] = index
                
                do {
                    let query = try createQuery(with: params)
                    
                    Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                        if error != nil {
                            print("Failed to get Pocket instance for getQuestList() with error:\(String(describing: error))")
                        }else{
                            _ = QuestDownloadParsing.parseDownload(dict: response!)
                        }
                    })
                } catch let error as NSError{
                    print(error)
                    return
                }
                index = index - 1
            }
        })
    }
    
    public static func getQuestListCount(handler: @escaping QuestCountHandler) {
        // getQuestAmount(address _tokenAddress) returns (uint)
        var params = [AnyHashable : Any]()
        var questAmount = Int32(0)
        
        params["_tokenAddress"] = "tokenaddress"
        
        do {
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
