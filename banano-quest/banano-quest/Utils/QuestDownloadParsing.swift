//
//  QuestDownloadParsing.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import Pocket
import CoreData

public class QuestDownloadParsing {
    static var mainContext: NSManagedObjectContext {
        get {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
            }
            return appDelegate.persistentContainer.viewContext
        }
    }
    
    static func parseDownload(dict: QueryResponse) -> Quest {
        // TODO: Parse download
        // return (quest.creator, quest.index, quest.name, quest.hint, quest.merkleRoot, quest.maxWinners,
        // quest.metadata, quest.valid, quest.winnersIndex.length, quest.claimersIndex.length)
        
        // Save each quest into core data
        let quest = Quest(obj: dict.result, context: self.mainContext)
        quest.save()
        
        return quest
    }
}
