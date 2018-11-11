//
//  DownloadBalanceOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/20/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket
import BigInt

public enum DownloadBalanceOperationError: Error {
    case responseParsing
}

public class DownloadBalanceOperation: AsynchronousOperation {
    
    public var address: String
    public var balance: BigInt?
    
    public init(address: String) {
        self.address = address
        super.init()
    }
    
    open override func main() {
        let params = [
            "rpcMethod": "eth_getBalance",
            "rpcParams": [address, "latest"]
        ] as [AnyHashable: Any]
        
        guard let query = try? PocketEth.createQuery(subnetwork: AppConfiguration.subnetwork, params: params, decoder: nil) else {
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
            
            guard let balanceHex: String = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
                self.error = DownloadBalanceOperationError.responseParsing
                self.finish()
                return
            }
            
            guard let balance = BigInt(balanceHex, radix: 16) else {
                self.error = DownloadBalanceOperationError.responseParsing
                self.finish()
                return
            }
            
            self.balance = balance
            self.finish()
        }
    }
}
