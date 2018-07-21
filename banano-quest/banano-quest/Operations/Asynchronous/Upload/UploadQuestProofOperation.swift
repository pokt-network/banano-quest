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

public enum UploadQuestProofOperationError: Error {
    case invalidTxHash
}

public class UploadQuestProofOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: Int64
    public var proof: [String]
    public var answer: String
    public var wallet: Wallet
    public var transactionCount: Int64
    
    public init(wallet: Wallet, transactionCount: Int64, tavernAddress: String, tokenAddress: String, questIndex: Int64, proof: [String], answer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.wallet = wallet
        self.transactionCount = transactionCount
        self.questIndex = questIndex
        self.proof = proof
        self.answer = answer
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_proof\",\"type\":\"bytes32[]\"},{\"name\":\"_answer\",\"type\":\"bytes32\"}],\"name\":\"submitProof\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        let functionParameters = [tokenAddress, questIndex, proof, answer] as [Any]
        let txParams = [
            "nonce": transactionCount + 1,
            "to": tavernAddress,
            "data": [
                "abi": functionABI,
                "params": functionParameters
                ] as [AnyHashable: Any]
            ] as [AnyHashable: Any]
        
        guard let transaction = try? PocketEth.createTransaction(wallet: wallet, params: txParams) else {
            self.error = PocketPluginError.transactionCreationError("Error creating transaction")
            self.finish()
            return
        }
        
        Pocket.shared.sendTransaction(transaction: transaction) { (transactionResponse, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let txHash = transactionResponse?.hash else {
                self.error = UploadQuestProofOperationError.invalidTxHash
                self.finish()
                return
            }
            
            self.txHash = txHash
            self.finish()
        }
    }
}

