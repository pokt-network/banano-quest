//
//  DownloadOwnerTokenCountOperation.swift
//  banano-quest
//
//  Created by MetaTedi on 10/9/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket
import BigInt

public enum DownloadOwnersTokenCountOperationError: Error {
    case totalOwnerTokenParsing
}

public class DownloadOwnersTokenCountOperation: AsynchronousOperation {
    
    public var leaderboardRecord: LeaderboardRecord?
    public var ownerIndex: Int
    public var bananoTokenAddress: String
    
    public init(bananoTokenAddress: String, ownerIndex:Int) {
        self.bananoTokenAddress = bananoTokenAddress
        self.ownerIndex = ownerIndex
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\": true,\"inputs\": [{\"name\": \"_ownerIndex\",\"type\": \"uint256\"}],\"name\": \"getOwnerTokenCountByIndex\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"},{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"}"
        let functionParameters = [ownerIndex] as [AnyObject]
        guard let data = try? PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString() else {
            self.error = PocketPluginError.queryCreationError("Error creating query")
            self.finish()
            return
        }
        
        tx["data"] = "0x" + data
        tx["to"] = bananoTokenAddress
        
        let params = [
            "rpcMethod": "eth_call",
            "rpcParams": [tx, "latest"]
            ] as [AnyHashable: Any]
        
        let decoder = [
            "returnTypes": ["address","uint256"]] as [AnyHashable : Any]
        
        guard let query = try? PocketEth.createQuery(subnetwork: AppConfiguration.subnetwork, params: params, decoder: decoder) else {
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
            guard let returnValues = queryResponse?.result?.value() as? [JSON] else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            guard let totalHexString = returnValues[1].value() as? String else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            let totalHexStringParsed = totalHexString.replacingOccurrences(of: "0x", with: "")
            
            guard let tokenCount = BigInt.init(totalHexStringParsed, radix: 16) else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            guard let wallet = returnValues.first?.value() as? String else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            
            self.leaderboardRecord = LeaderboardRecord()
            self.leaderboardRecord?.wallet = wallet
            self.leaderboardRecord?.tokenTotal = tokenCount
            
            ///TODO: Set the count
            self.finish()
        }
    }
    
}
