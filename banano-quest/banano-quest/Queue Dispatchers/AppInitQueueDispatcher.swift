//
//  AppInitQueueDispatcher.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public class AppInitQueueDispatcher: QueueDispatcherProtocol {
    
    private let operationQueue: OperationQueue = OperationQueue()
    private let downloadBalanceOperation: DownloadBalanceOperation
    private let transactionCountOperation: DownloadTransactionCountOperation
    private let questAmounOperation: DownloadQuestAmountOperation
    private let ethUsdPriceOperation: DownloadEthUsdPriceOperation
    private var completionHandler: QueueDispatcherCompletionHandler?
    
    public init(playerAddress: String, tavernAddress: String, bananoTokenAddress: String) {
        // Init operations
        self.downloadBalanceOperation = DownloadBalanceOperation.init(address: playerAddress)
        self.transactionCountOperation = DownloadTransactionCountOperation.init(address: playerAddress)
        self.questAmounOperation = DownloadQuestAmountOperation.init(tavernAddress: tavernAddress, tokenAddress: bananoTokenAddress)
        self.ethUsdPriceOperation = DownloadEthUsdPriceOperation.init()
        self.setOperationsCompletionBlocks()
    }
    
    public func initDisplatchSequence(completionHandler: QueueDispatcherCompletionHandler?) {
        self.completionHandler = completionHandler
        self.operationQueue.addOperations([self.downloadBalanceOperation, self.transactionCountOperation, self.questAmounOperation, self.ethUsdPriceOperation], waitUntilFinished: false)
    }
    
    public func isQueueFinished() -> Bool {
        return self.operationQueue.operations.reduce(into: true) { (result, currOperation) in
            if currOperation.isFinished == false {
                result = false
            }
        }
    }
    
    public func cancelAllOperations() {
        self.operationQueue.cancelAllOperations()
    }
    
    // Private interfaces
    private func attempToExecuteCompletionHandler() {
        if self.isQueueFinished() {
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
            
            // Update the player record
            self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: self.downloadBalanceOperation.balance, transactionCount: self.transactionCountOperation.transactionCount, questAmount: self.questAmounOperation.questAmount, ethUsdPrice: self.ethUsdPriceOperation.usdPrice))
        }
    }
    
    private func setOperationsCompletionBlocks() {
        self.downloadBalanceOperation.completionBlock = {
            self.attempToExecuteCompletionHandler()
        }
        
        self.transactionCountOperation.completionBlock = {
            self.attempToExecuteCompletionHandler()
        }
        
        self.questAmounOperation.completionBlock = {
            self.attempToExecuteCompletionHandler()
        }
        
        self.ethUsdPriceOperation.completionBlock = {
            self.attempToExecuteCompletionHandler()
        }
    }
    
}
