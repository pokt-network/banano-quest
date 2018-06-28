//
//  QuestDownloadParsing.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import Pocket

public class QuestDownloadParsing {
   static let mainContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    static func parseDownload(dict: QueryResponse) {
        // TODO: Parse download
        // return (quest.creator, quest.index, quest.name, quest.hint, quest.merkleRoot, quest.maxWinners,
        // quest.metadata, quest.valid, quest.winnersIndex.length, quest.claimersIndex.length)
        
        // Save each quest into core data
        let quest = Quest(obj: dict.result, context: self.mainContext)
        quest.save()
        // Save each quest into core data
    }
}
