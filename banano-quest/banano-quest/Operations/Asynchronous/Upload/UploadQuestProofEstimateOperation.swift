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

public enum UploadQuestProofEstimateOperationError: Error {
    case resultParsing
}

public class UploadQuestProofEstimateOperation: AsynchronousOperation {
    
    public var estimatedGasWei: Int64?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var proof: [String]
    public var answer: String
    public var wallet: Wallet
    
    public init(wallet: Wallet, tavernAddress: String, tokenAddress: String, questIndex: Int64, proof: [String], answer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.wallet = wallet
        self.questIndex = questIndex
        self.proof = proof
        self.answer = answer
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_proof\",\"type\":\"bytes32[]\"},{\"name\":\"_answer\",\"type\":\"bytes32\"}],\"name\":\"submitProof\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questIndex, proof, answer] as [AnyObject]
        let txParams = [
            "from": wallet.address,
            "to": tavernAddress,
            "data": PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters)
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
                self.error = UploadQuestProofEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            guard let estimatedGas = Int64(estimatedGasHex, radix: 16) else {
                self.error = UploadQuestProofEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            self.estimatedGasWei = estimatedGas
            self.finish()
        }
    }
}

