//
//  TransactionReceipt.swift
//  banano-quest
//
//  Created by Luis De Leon on 8/13/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import Pocket

public enum TransactionStatus {
    case success
    case failure
}

public struct TransactionReceipt {
    
    public var rawReceipt: [String: JSON]
    // Parsed properties of the rawReceipt
    public var status: TransactionStatus {
        get {
            if let rawStatus = rawReceipt["status"]?.value() as? String {
                switch rawStatus {
                    case "0x0":
                        return .failure
                    case "0x1":
                        return .success
                    default:
                        return .failure
                }
            } else {
                return .failure
            }
        }
    }
    
    public init(rawReceipt: [String: JSON]) {
        self.rawReceipt = rawReceipt
    }
    
}
