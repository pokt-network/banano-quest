//
//  Transaction+CoreDataProperties.swift
//  
//
//  Created by Luis De Leon on 8/12/18.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var notified: Bool
    @NSManaged public var receipt: NSData?
    @NSManaged public var txHash: String
    @NSManaged public var type: String

}
