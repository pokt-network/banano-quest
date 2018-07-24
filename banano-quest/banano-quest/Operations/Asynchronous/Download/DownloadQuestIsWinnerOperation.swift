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

public enum DownloadQuestIsWinnerOperationError: Error {
    case resultParsing
}

public class DownloadQuestIsWinnerOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var alledgedWinner: String
    public var isWinner: Bool?
    
    public init(tavernAddress: String, tokenAddress: String, questIndex: Int64, alledgedWinner: String) {
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
        tx["to"] = tavernAddress
        tx["data"] = "0x" + PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString()
        
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
            
            guard let isWinnerBool = queryResponse?.result?.value() as? Bool else {
                self.error = DownloadQuestIsWinnerOperationError.resultParsing
                self.finish()
                return
            }
            
            self.isWinner = isWinnerBool
            self.finish()
        }
    }
}
