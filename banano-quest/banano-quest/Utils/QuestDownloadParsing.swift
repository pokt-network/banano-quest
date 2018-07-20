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
    
    static func parseDownload(dict: QueryResponse) throws -> Quest {
        // TODO: Parse download
        // return (quest.creator, quest.index, quest.name, quest.hint, quest.merkleRoot, quest.maxWinners,
        // quest.metadata, quest.valid, quest.winnersIndex.length, quest.claimersIndex.length)
        
        // Save each quest into core data
        let metadata = [AnyHashable: Any]()
        let quest = try Quest(obj: [:], metadata: metadata, context: BaseUtil.mainContext)
        
        return quest
    }
}
