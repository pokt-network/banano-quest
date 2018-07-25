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
import BigInt

public enum DownloadTransactionCountOperationError: Error {
    case responseParsing
}

public class DownloadTransactionCountOperation: AsynchronousOperation {
    
    public var address: String
    public var transactionCount: BigInt?
    
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
            
            guard let transactionCountHex = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
                self.error = DownloadTransactionCountOperationError.responseParsing
                self.finish()
                return
            }
            
            guard let transactionCount = BigInt.init(transactionCountHex, radix: 16) else {
                self.error = DownloadTransactionCountOperationError.responseParsing
                self.finish()
                return
            }
            
            self.transactionCount = transactionCount
            self.finish()
        }
    }
}
