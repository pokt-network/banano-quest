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

public class Networking {
    static let nodeURL = URL.init(string: "https://node.url")
    
    public static func getQuestList() {

        var params = [AnyHashable : Any]()
        let count = getQuestListCount()
        var index = count - 1

        while index >= 0{
            params["_tokenAddress"] = "tokenaddress"
            params["_questIndex"] = index
            
            let query = createQuery(with: params)
            
            Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
                if error != nil {
                    print("")
                }else{
                    // TODO: parse response
                    QuestDownloadParsing.parseDownload(dict: response!)
                    print("")
                }
            })
            index = index - 1
        }
        // Refresh current view
        guard let activeVC = UIApplication.shared.delegate?.window??.rootViewController as? BananoQuestView else{
            print("")
            return
        }
        activeVC.refreshView()
        
    }
    
    public static func getQuestListCount() -> Int32 {
        // getQuestAmount(address _tokenAddress) returns (uint)
        var params = [AnyHashable : Any]()
        var questAmount = Int32(0)
        
        params["_tokenAddress"] = "tokenaddress"
        
        let query = createQuery(with: params)
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error != nil {
                print("")
            }else{
                questAmount = response?.result!["length"] as? Int32 ?? 0
                print("")
            }
        })
        return questAmount
    }
    
    static func createQuery(with params: [AnyHashable : Any]) -> Query {
        var query = Query()
        
        do {
            query = try PocketEth.createQuery(params: [AnyHashable : Any](), decoder: [AnyHashable : Any]())
        } catch {
            print("")
        }
        return query
    }
    
    public static func uploadNewQuest(quest: Quest) -> Bool {
        let params = [AnyHashable : Any]()
        let query = createQuery(with: params)
        var result = false
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                result = true
            }
        })
        
        return result
    }
    
    public static func uploadQuestCompletion(quest: Quest, locations: [AnyHashable: Any]) -> Bool {
        let params = [AnyHashable : Any]()
        let query = createQuery(with: params)
        var result = false
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                result = true
            }
        })
        return result
    }
}
