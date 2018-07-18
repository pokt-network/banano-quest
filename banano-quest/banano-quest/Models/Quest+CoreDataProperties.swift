//
//  Quest+CoreDataProperties.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 6/26/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
//

import Foundation
import CoreData

public typealias QuestListCompletionHandler = (_: [Quest]?, _: Error?) -> Void

extension Quest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quest> {
        return NSFetchRequest<Quest>(entityName: "Quest")
    }

    @NSManaged public var creator: String?
    @NSManaged public var name: String?
    @NSManaged public var hint: String?
    @NSManaged public var merkleRoot: String?
    @NSManaged public var merkleBody: String?
    @NSManaged public var maxWinners: Int16
    @NSManaged public var questID: Int32
    @NSManaged public var prize: Double
    @NSManaged public var winners: Winners?
    @NSManaged public var metadata: Metadata?

}

extension Quest {
    public static func retrieveQuestList(handler: @escaping QuestListCompletionHandler) throws {
        // Quests list retrieved from CoreData
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        do {            
            // Sync quest list
            try Networking.getQuestList { (error) in
                do {
                    // Retrieve quest list from coreData
                    quests = try BaseUtil.mainContext.fetch(fetchRequest) as [Quest]
                    handler(quests,nil)
                }
                catch let error as NSError {
                    handler(nil,error)
                }
            }
            
        }
        catch let error as NSError {
            handler(nil,error)
        }
        

    }
}
