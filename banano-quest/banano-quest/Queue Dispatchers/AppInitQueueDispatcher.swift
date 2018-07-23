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
        self.operationQueue.addOperations([self.downloadBalanceOperation, self.transactionCountOperation, self.questAmounOperation, self.ethUsdPriceOperation], waitUntilFinished: true)
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
        if self.isQueueFinished(), let completionHandler = self.completionHandler {
            completionHandler()
        }
    }
    
    private func setOperationsCompletionBlocks() {
        self.downloadBalanceOperation.completionBlock = {
            if self.downloadBalanceOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: self.downloadBalanceOperation.balance, transactionCount: nil, questAmount: nil, ethUsdPrice: nil))
            }
            self.attempToExecuteCompletionHandler()
        }
        
        self.transactionCountOperation.completionBlock = {
            if self.transactionCountOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: self.transactionCountOperation.transactionCount, questAmount: nil, ethUsdPrice: nil))
            }
            self.attempToExecuteCompletionHandler()
        }
        
        self.questAmounOperation.completionBlock = {
            if self.questAmounOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: nil, questAmount: self.questAmounOperation.questAmount, ethUsdPrice: nil))
            }
            self.attempToExecuteCompletionHandler()
        }
        
        self.ethUsdPriceOperation.completionBlock = {
            if self.ethUsdPriceOperation.finishedSuccesfully {
                self.operationQueue.addOperation(UpdatePlayerOperation.init(balanceWei: nil, transactionCount: nil, questAmount: nil, ethUsdPrice: self.ethUsdPriceOperation.usdPrice))
            }
            self.attempToExecuteCompletionHandler()
        }
    }
    
}
