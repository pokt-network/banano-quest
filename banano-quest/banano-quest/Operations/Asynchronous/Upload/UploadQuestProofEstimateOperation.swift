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
    case invalidTxHash
}

public class UploadQuestProofEstimateOperation: AsynchronousOperation {
    
    public var estimatedGasWei: String?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var proof: [String]
    public var answer: String
    
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
        let functionParameters = [tokenAddress, questIndex, proof, answer] as [Any]
        let txParams = [
            "to": tavernAddress,
            "data": [
                "abi": functionABI,
                "params": functionParameters
                ] as [AnyHashable: Any]
            ] as [AnyHashable: Any]
    }
}

