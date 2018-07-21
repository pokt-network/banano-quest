//
//  UploadQuestOperation.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/20/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import PocketEth
import Pocket

public enum UploadQuestEstimateOperationError: Error {
    case resultParsing
}

public class UploadQuestEstimateOperation: AsynchronousOperation {
    
    public var estimatedGasWei: Int64?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questName: String
    public var hint: String
    public var maxWinners: Int64
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var wallet: Wallet
    public var ethPrizeWei: Int64
    
    public init(wallet: Wallet, tavernAddress: String, tokenAddress: String, questName: String, hint: String, maxWinners: Int64, merkleRoot: String, merkleBody: String, metadata: String, ethPrizeWei: Int64) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.questName = questName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.ethPrizeWei = ethPrizeWei
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_maxWinners\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_merkleBody\",\"type\":\"string\"},{\"name\":\"_metadata\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questName, hint, maxWinners, merkleRoot, merkleBody, metadata] as [Any]
        
        let txParams = [
            "to": tavernAddress,
            "value": ethPrizeWei,
            "data": PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters as [AnyObject]).toHexString()
            ] as [AnyHashable: Any]
        
        let params = [
            "rpcMethod": "eth_estimateGas",
            "rpcParams": [txParams, "latest"]
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
            
            guard let estimatedGasHex = queryResponse?.stringResult else {
                self.error = UploadQuestEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            guard let estimatedGas = Int64(estimatedGasHex, radix: 16) else {
                self.error = UploadQuestEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            self.estimatedGasWei = estimatedGas
            self.finish()
        }
    }
}
