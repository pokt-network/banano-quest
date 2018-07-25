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
    public var questDict: [AnyHashable: Any]?
    
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
        guard let data = try? PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString() else {
            self.error = PocketPluginError.queryCreationError("Error creating query")
            self.finish()
            return
        }
        
        tx["to"] = tavernAddress
        tx["data"] = "0x" + data
        
        let params = [
            "rpcMethod": "eth_call",
            "rpcParams": [tx, "latest"]
            ] as [AnyHashable: Any]
        
        let decoder = [
            "returnTypes": ["address", "uint256", "string", "string", "bytes32", "string", "uint256", "string", "bool", "uint256", "uint256"]
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
            
            guard let questArr = queryResponse?.result?.value() as? [JSON] else {
                self.error = DownloadQuestOperationError.questParsing
                self.finish()
                return
            }
            
            let creator = questArr[0].value() as? String ?? ""
            let index = questArr[1].value() as? Int ?? 0
            let name = questArr[2].value() as? String ?? ""
            let hint = questArr[3].value() as? String ?? ""
            let merkleRoot = questArr[4].value() as? String ?? ""
            let merkleBody = questArr[5].value() as? String ?? ""
            let maxWinners = questArr[6].value() as? Int ?? 0
            let metadata = questArr[7].value() as? String ?? ""
            let valid = questArr[8].value() as? Bool ?? false
            let winnersAmount = questArr[9].value() as? Int ?? 0
            let claimersAmount = questArr[10].value() as? Int ?? 0
            
            self.questDict = [
                "creator": creator,
                "index": index,
                "name": name,
                "hint": hint,
                "merkleRoot": merkleRoot,
                "merkleBody": merkleBody,
                "maxWinners": maxWinners,
                "metadata": metadata,
                "valid": valid,
                "winnersAmount": winnersAmount,
                "claimersAmount": claimersAmount
            ] as [AnyHashable: Any]
            self.finish()
        }
    }
    
}
