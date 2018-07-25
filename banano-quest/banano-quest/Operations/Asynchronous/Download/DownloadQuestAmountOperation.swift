//
//  DownloadQuestAmountOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/20/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket

public enum DownloadQuestAmountOperationError: Error {
    case amountParsing
}

public class DownloadQuestAmountOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var questAmount: Int64?
    
    public init(tavernAddress: String, tokenAddress: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"}],\"name\":\"getQuestAmount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress] as [AnyObject]
        guard let data = try? PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString() else {
            self.error = PocketPluginError.queryCreationError("Query creation error")
            self.finish()
            return
        }
        
        tx["to"] = tavernAddress
        tx["data"] = "0x" + data
        
        let params = [
            "rpcMethod": "eth_call",
            "rpcParams": [tx, "latest"]
            ] as [AnyHashable: Any]
        
        guard let query = try? PocketEth.createQuery(params: params, decoder: nil) else {
            self.error = PocketPluginError.queryCreationError("Query creation error")
            self.finish()
            return
        }
        
        Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let questAmountHex = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
                self.error = DownloadQuestAmountOperationError.amountParsing
                self.finish()
                return
            }
            
            guard let questAmount = Int64(questAmountHex, radix: 16) else {
                self.error = DownloadQuestAmountOperationError.amountParsing
                self.finish()
                return
            }
            
            self.questAmount = questAmount
            self.finish()
        }
    }
    
}
