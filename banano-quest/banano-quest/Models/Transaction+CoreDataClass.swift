//
//  Transaction+CoreDataClass.swift
//  
//
//  Created by Luis De Leon on 8/12/18.
//
//

import Foundation
import CoreData

public enum TransactionType: String {
    case creation = "creation"
    case claim = "claim"
}

@objc(Transaction)
public class Transaction: NSManagedObject {
    
    // MARK: - Init
    convenience init(txHash: String, type: TransactionType, context: NSManagedObjectContext) {
        self.init(context: context)
        self.type = type.rawValue
        self.txHash = txHash
        self.notified = false
    }
    
    // MARK: - CRUD
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    // MARK: - Convenience list retrieval
    public static func unnotifiedTransactionsPerType(context: NSManagedObjectContext, txType: TransactionType) throws -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notified == NO AND type == %@", txType.rawValue)
        return try context.fetch(fetchRequest) as [Transaction]
    }

}
