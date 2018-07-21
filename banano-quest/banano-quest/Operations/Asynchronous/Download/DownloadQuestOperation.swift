//
//  DownloadQuest.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/20/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket

public enum DownloadQuestOperationError: Error {
    case questParsing
}

public class DownloadQuestOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var queryDict: [AnyHashable: Any]?
    
    public init(tavernAddress: String, tokenAddress: String, questIndex: Int64) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.questIndex = questIndex
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"}],\"name\":\"getQuest\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bool\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questIndex] as [AnyObject]
        tx["to"] = tavernAddress
        tx["data"] = PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString()
        
        let params = [
            "rpcMethod": "eth_call",
            "rpcParams": [tx, "latest"]
            ] as [AnyHashable: Any]
        
        let decoder = [
            "returnTypes": ["address", "uint", "string", "string", "bytes32", "string", "uint", "string", "bool", "uint", "uint"]
        ] as [AnyHashable : Any]
        
        guard let query = try? PocketEth.createQuery(params: params, decoder: decoder) else {
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
            
            guard let questArr = queryResponse?.arrResult else {
                self.error = DownloadQuestOperationError.questParsing
                self.finish()
                return
            }
            
            self.queryDict = [
                "creator": questArr[0],
                "index": questArr[1],
                "name": questArr[2],
                "hint": questArr[3],
                "merkleRoot": questArr[4],
                "merkleBody": questArr[5],
                "maxWinners": questArr[6],
                "metadata": questArr[7],
                "valid": questArr[8],
                "winnersAmount": questArr[9],
                "claimersAmount": questArr[10]
            ] as [AnyHashable: Any]
            self.finish()
        }
    }
    
}
