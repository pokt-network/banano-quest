//
//  DownloadTransactionReceiptOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 8/12/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket
import BigInt

public enum DownloadTransactionReceiptOperationError: Error {
    case responseParsing
}

public class DownloadTransactionReceiptOperation: AsynchronousOperation {
    
    public var txHash: String
    public var txReceipt: TransactionReceipt?
    
    public init(txHash: String) {
        self.txHash = txHash
        super.init()
    }
    
    open override func main() {
        let params = [
            "rpcMethod": "eth_getTransactionReceipt",
            "rpcParams": [txHash]
            ] as [AnyHashable: Any]
        
        guard let query = try? PocketEth.createQuery(params: params, decoder: nil) else {
            self.error = PocketPluginError.queryCreationError("Error creating query")
            self.finish()
            return
        }
        
        Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let rawReceipt = queryResponse?.result?.value() as? [String: JSON] else {
                self.error = DownloadTransactionReceiptOperationError.responseParsing
                self.finish()
                return
            }
            
            self.txReceipt = TransactionReceipt.init(rawReceipt: rawReceipt)
            self.finish()
        }
    }
}

