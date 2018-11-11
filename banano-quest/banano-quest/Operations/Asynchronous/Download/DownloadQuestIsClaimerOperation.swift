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

public enum DownloadQuestIsClaimerOperationError: Error {
    case resultParsing
}

public class DownloadQuestIsClaimerOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var alledgedClaimer: String
    public var isClaimer: Bool?
    
    public init(tavernAddress: String, tokenAddress: String, questIndex: Int64, alledgedClaimer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.questIndex = questIndex
        self.alledgedClaimer = alledgedClaimer
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_allegedClaimer\",\"type\":\"address\"}],\"name\":\"isClaimer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questIndex, alledgedClaimer] as [AnyObject]
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
        
        guard let query = try? PocketEth.createQuery(subnetwork: AppConfiguration.subnetwork, params: params, decoder: nil) else {
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
            
            guard let isClaimerBool = queryResponse?.result?.value() as? Bool else {
                self.error = DownloadQuestIsClaimerOperationError.resultParsing
                self.finish()
                return
            }
            
            self.isClaimer = isClaimerBool
            self.finish()
        }
    }
}
