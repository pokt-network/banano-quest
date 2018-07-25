
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

public enum UploadQuestOperationError: Error {
    case invalidTxHash
}

public class UploadQuestOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var tavernAddress: String
    public var tokenAddress: String
    public var questName: String
    public var hint: String
    public var maxWinners: BigInt
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var wallet: Wallet
    public var transactionCount: BigInt
    public var ethPrizeWei: BigInt
    
    public init(wallet: Wallet, tavernAddress: String, tokenAddress: String, questName: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String, transactionCount: BigInt, ethPrizeWei: BigInt) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.questName = questName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.wallet = wallet
        self.transactionCount = transactionCount
        self.ethPrizeWei = ethPrizeWei
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_maxWinners\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_merkleBody\",\"type\":\"string\"},{\"name\":\"_metadata\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"
        var functionParameters = [AnyObject]()
        functionParameters.append(tokenAddress as AnyObject)
        functionParameters.append(questName.description as AnyObject)
        functionParameters.append(hint.description as AnyObject)
        functionParameters.append(maxWinners as AnyObject)
        functionParameters.append(merkleRoot as AnyObject)
        functionParameters.append(merkleBody as AnyObject)
        functionParameters.append(metadata as AnyObject)
        
        let txParams = [
            "from": wallet.address,
            "nonce": BigUInt.init(transactionCount),
            "to": tavernAddress,
            "value": BigUInt.init(ethPrizeWei),
            "chainID": AppConfiguration.chainID,
            "gasLimit": BigUInt.init(2000000),
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
                self.error = UploadQuestOperationError.invalidTxHash
                self.finish()
                return
            }
            
            self.txHash = txHash
            self.finish()
        }
    }
}
