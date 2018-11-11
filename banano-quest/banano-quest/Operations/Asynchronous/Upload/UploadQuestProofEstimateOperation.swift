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
import BigInt

public enum UploadQuestProofEstimateOperationError: Error {
    case resultParsing
}

public class UploadQuestProofEstimateOperation: AsynchronousOperation {
    
    public var estimatedGasWei: BigInt?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: BigInt
    public var proof: [String]
    public var answer: String
    public var playerAddress: String
    
    public init(playerAddress: String, tavernAddress: String, tokenAddress: String, questIndex: BigInt, proof: [String], answer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.playerAddress = playerAddress
        self.questIndex = questIndex
        self.proof = proof
        self.answer = answer
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_proof\",\"type\":\"bytes32[]\"},{\"name\":\"_answer\",\"type\":\"bytes32\"}],\"name\":\"submitProof\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        var functionParameters = [AnyObject]()
        functionParameters.append(tokenAddress as AnyObject)
        functionParameters.append(questIndex as AnyObject)
        functionParameters.append(proof as AnyObject)
        functionParameters.append(answer as AnyObject)
        guard let data = try? PocketEth.encodeFunction(functionABI: functionABI, parameters: functionParameters).toHexString() else {
            self.error = PocketPluginError.queryCreationError("Query creation error")
            self.finish()
            return
        }
        
        let txParams = [
            "from": playerAddress,
            "to": tavernAddress,
            "data": "0x" + data
        ] as [AnyHashable: Any]
        let params = [
            "rpcMethod": "eth_estimateGas",
            "rpcParams": [txParams]
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
            
            guard let estimatedGasHex = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
                self.error = UploadQuestProofEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            guard let estimatedGas = BigInt.init(estimatedGasHex, radix: 16) else {
                self.error = UploadQuestProofEstimateOperationError.resultParsing
                self.finish()
                return
            }
            
            self.estimatedGasWei = estimatedGas * BigInt.init(1000000000)
            self.finish()
        }
    }
}

