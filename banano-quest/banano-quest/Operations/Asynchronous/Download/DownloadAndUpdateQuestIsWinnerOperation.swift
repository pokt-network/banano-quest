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
import BigInt

public enum DownloadAndUpdateQuestIsWinnerOperationError: Error {
    case resultParsing
    case updating
}

public class DownloadAndUpdateQuestIsWinnerOperation: AsynchronousOperation {
    
    private var tavernAddress: String
    private var tokenAddress: String
    private var questIndex: BigInt
    private var alledgedWinner: String
    
    public init(tavernAddress: String, tokenAddress: String, questIndex: BigInt, alledgedWinner: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.questIndex = questIndex
        self.alledgedWinner = alledgedWinner
        super.init()
    }
    
    open override func main() {
        var tx = [AnyHashable: Any]()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_allegedWinner\",\"type\":\"address\"}],\"name\":\"isWinner\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questIndex, alledgedWinner] as [AnyObject]
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
        
        let decoder = [
            "returnTypes": ["bool"]
            ] as [AnyHashable : Any]
        
        guard let query = try? PocketEth.createQuery(params: params, decoder: decoder) else {
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
            
            guard let returnValues = queryResponse?.result?.value() as? [JSON] else {
                self.error = DownloadAndUpdateQuestIsWinnerOperationError.resultParsing
                self.finish()
                return
            }
            
            guard let isWinnerBool = returnValues.first?.value() as? Bool else {
                self.error = DownloadAndUpdateQuestIsWinnerOperationError.resultParsing
                self.finish()
                return
            }
            
            do {
                let context = CoreDataUtil.backgroundPersistentContext
                guard let quest = Quest.getQuestByIndex(questIndex: String.init(self.questIndex), context: context) else {
                    self.error = DownloadAndUpdateQuestIsWinnerOperationError.updating
                    self.finish()
                    return
                }
                quest.winner = isWinnerBool
                try quest.save()
            } catch {
                self.error = DownloadAndUpdateQuestIsWinnerOperationError.updating
                self.finish()
                return
            }
            self.finish()
        }
    }
}
