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
                    print("Failed to get Pocket instance for getQuestList() with error:\(String(describing: error))")
                }else{
                    // TODO: parse response
                    QuestDownloadParsing.parseDownload(dict: response!)
                }
            })
            index = index - 1
        }
        // Refresh current view
        refreshCurrentViewController()
        
    }
    
    public static func getQuestListCount() -> Int32 {
        // getQuestAmount(address _tokenAddress) returns (uint)
        var params = [AnyHashable : Any]()
        var questAmount = Int32(0)
        
        params["_tokenAddress"] = "tokenaddress"
        
        let query = createQuery(with: params)
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error != nil {
                print("Failed to get Pocket Instance for getQuestListCount() with error:\(String(describing: error))")
            }else{
                questAmount = response?.result!["length"] as? Int32 ?? 0
            }
        })
        return questAmount
    }
    
    static func createQuery(with params: [AnyHashable : Any]) -> Query {
        var query = Query()
        
        do {
            query = try PocketEth.createQuery(params: [AnyHashable : Any](), decoder: [AnyHashable : Any]())
        } catch let error as NSError{
            print("Failed to create Query with error:\(error)")
        }
        return query
    }
    
    public static func uploadNewQuest(quest: Quest) {
        let params = [AnyHashable : Any]()
        let query = createQuery(with: params)
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                // Refresh current view
                refreshCurrentViewController()
            }else{
                print("Failed to execute uploadNewQuest() with error:\(String(describing: error))")
            }
        })
    }
    
    public static func uploadQuestCompletion(quest: Quest, locations: [AnyHashable: Any]) {
        let params = [AnyHashable : Any]()
        let query = createQuery(with: params)
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                // Refresh current view
                refreshCurrentViewController()
            }else{
                print("Failed to execute uploadQuestCompletion() with error:\(String(describing: error))")
            }
        })
    }
    
    private static func refreshCurrentViewController() {
        guard let activeVC = UIApplication.shared.delegate?.window??.rootViewController as? BananoQuestView else{
            print("Failed to instantiate current viewController, returning.")
            return
        }
        activeVC.refreshView()
    }
}
