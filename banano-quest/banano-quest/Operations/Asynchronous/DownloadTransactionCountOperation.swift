//
//  DownloadTransactionCountOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/20/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket

public enum DownloadTransactionCountOperationError: Error {
    case responseParsing
}

public class DownloadTransactionCountOperation: AsynchronousOperation {
    
    public var address: String
    public var transactionCount: Int64?
    
    public init(address: String) {
        self.address = address
        super.init()
    }
    
    open override func main() {
        let params = [
            "rpcMethod": "eth_getTransactionCount",
            "rpcParams": [address, "latest"]
            ] as [AnyHashable: Any]
        
        guard let query = try? PocketEth.createQuery(params: params, decoder: nil) else {
            self.finish()
            return
        }
        
        Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let transactionCountHex = queryResponse?.stringResult else {
                self.error = DownloadTransactionCountOperationError.responseParsing
                self.finish()
                return
            }
            
            guard let transactionCount = Int64(transactionCountHex, radix: 16) else {
                self.error = DownloadTransactionCountOperationError.responseParsing
                self.finish()
                return
            }
            
            self.transactionCount = transactionCount
            self.finish()
        }
    }
}
