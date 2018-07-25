//
//  UpdateQuestOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import CoreData

public enum UpdateQuestOperationError: Error {
    case questFetchError
}

public class UpdateQuestOperation: SynchronousOperation {
    
    private var questDict: [AnyHashable: Any]
    private var questIndex: String
    
    public init(questDict: [AnyHashable: Any], questIndex: String) {
        self.questDict = questDict
        self.questIndex = questIndex
        super.init()
    }
    
    open override func main() {
        do {
            let context = try CoreDataUtil.backgroundPersistentContext(mergePolicy: NSMergePolicy.mergeByPropertyObjectTrump)
            let quest = try Quest.init(obj: questDict, context: context)
            try quest.save()
        } catch {
            self.error = error
            return
        }
    }
}
