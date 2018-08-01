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

public enum UploadQuestProofOperationError: Error {
    case invalidTxHash
}

public class UploadQuestProofOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questIndex: BigInt
    public var proof: [String]
    public var answer: String
    public var wallet: Wallet
    public var transactionCount: BigInt
    
    public init(wallet: Wallet, transactionCount: BigInt, tavernAddress: String, tokenAddress: String, questIndex: BigInt, proof: [String], answer: String) {
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
        var functionParameters = [AnyObject]()
        functionParameters.append(tokenAddress as AnyObject)
        functionParameters.append(questIndex as AnyObject)
        functionParameters.append(proof as AnyObject)
        functionParameters.append(answer as AnyObject)
        let txParams = [
            "from": wallet.address,
            "nonce": BigUInt.init(transactionCount),
            "to": tavernAddress,
            "chainID": AppConfiguration.chainID,
            "gasLimit": BigUInt.init(6000000),
            "gasPrice": BigUInt.init(1000000000),
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

