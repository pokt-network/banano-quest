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
    @NSManaged public var maxWinners: Int64
    @NSManaged public var index: Int64
    @NSManaged public var prize: Double
    @NSManaged public var winners: Winners?
    @NSManaged public var winnersAmount: Int64
    @NSManaged public var claimersAmount: Int64
    @NSManaged public var metadata: String?
    @NSManaged public var hexColor: String?
    @NSManaged public var lat1: Float
    @NSManaged public var lat2: Float
    @NSManaged public var lat3: Float
    @NSManaged public var lat4: Float
    @NSManaged public var lon1: Float
    @NSManaged public var lon2: Float
    @NSManaged public var lon3: Float
    @NSManaged public var lon4: Float
    @NSManaged public var isWinner: Bool
    @NSManaged public var isClaimer: Bool

}

extension Quest {
    public static func retrieveQuestList(handler: @escaping QuestListCompletionHandler) throws {
        // Quests list retrieved from CoreData
        var quests = [Quest]()
        
        let fetchRequest = NSFetchRequest<Quest>(entityName: "Quest")
        
        do {            
            // Sync quest list
//            try Networking.getQuestList { (error) in
//                do {
//                    // Retrieve quest list from coreData
//                    quests = try BaseUtil.mainContext.fetch(fetchRequest) as [Quest]
//                    handler(quests,nil)
//                }
//                catch let error as NSError {
//                    handler(nil,error)
//                }
//            }
            
        }
        catch let error as NSError {
            handler(nil,error)
        }
        

    }
}
