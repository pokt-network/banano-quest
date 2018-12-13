//
//  DownloadTotalWalletsOperation.swift
//  banano-quest
//
//  Created by MetaTedi on 9/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//
import Foundation
import PocketEth
import Pocket
import BigInt

public enum DownloadOwnersCountOperationError: Error {
    case totalOwnerParsing
}

public class DownloadOwnersCountOperation: AsynchronousOperation {
    
    var total: BigInt?
    public var bananoTokenAddress: String

    
    public init(bananoTokenAddress: String) {
        self.bananoTokenAddress = bananoTokenAddress
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\":true,\"inputs\":[],\"name\":\"getOwnersCount\",\"outputs\":[{\"name\": \"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        let functionParameters = [] as [AnyObject]
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
            "returnTypes": "uint256"
            ] as [AnyHashable : Any]
        
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
            
            guard let totalHexString = queryResponse?.result?.value() as? String else {
                self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                self.finish()
                return
            }
            let totalHexStringParsed = totalHexString.replacingOccurrences(of: "0x", with: "")
    
            guard let totalAmount = BigInt.init(totalHexStringParsed, radix: 16) else {
                self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                self.finish()
                return
            }
            self.total = totalAmount
            self.finish()
        }
    }
    
}
