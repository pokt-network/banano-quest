//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Luis De Leon on 7/19/18.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var address: String?
    @NSManaged public var balanceWei: String
    @NSManaged public var transactionCount: String
    @NSManaged public var tavernQuestAmount: String
    @NSManaged public var ethUsdPrice: Double

}
