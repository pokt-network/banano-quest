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
    
    public static func downloadQuestList() {
        var query = Query()

        do {
            query = try PocketEth.createQuery(params: [AnyHashable : Any](), decoder: [AnyHashable : Any]())
        } catch {
            print("")
        }
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error != nil {
                print("")
            }else{
                // TODO: parse response
                QuestDownloadParsing.parseDownload(dict: response)
                print("")
            }
        })
        
    }
    
    public static func uploadNewQuest(quest: Quest) -> Bool {
        var query = Query()
        var result = false
        // TODO: Add query params using the Quest model object
        do {
            query = try PocketEth.createQuery(params: quest.dictionary(), decoder: [AnyHashable : Any]())
        } catch {
            print("")
        }
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                result = true
            }
        })
        
        return result
    }
    
    public static func uploadQuestCompletion(quest: Quest, locations: [AnyHashable: Any]) -> Bool {
        var query = Query()
        var result = false
        // TODO: Add query params using the Quest model object and user locations
        do {
            query = try PocketEth.createQuery(params: [AnyHashable : Any](), decoder: [AnyHashable : Any]())
        } catch {
            print("")
        }
        
        Pocket.getInstance(pocketNodeURL: nodeURL!).executeQuery(query: query, handler: { (response, error) in
            if error == nil {
                result = true
            }
        })
        return result
    }
}
