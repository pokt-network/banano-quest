//
//  AllQuestsQueueDispatcher.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public class AllQuestsQueueDispatcher: QueueDispatcherProtocol {
    
    private var completionHandler: QueueDispatcherCompletionHandler?
    private var currentQuestIndex: Int64?
    private var tavernQuestAmount: Int64?
    private let tavernAddress: String
    private let bananoTokenAddress: String
    private let operationQueue = OperationQueue.init()
    
    public init(tavernQuestAmount: Int64, tavernAddress: String, bananoTokenAddress: String) {
        self.tavernQuestAmount = tavernQuestAmount
        self.tavernAddress = tavernAddress
        self.bananoTokenAddress = bananoTokenAddress
//        if self.tavernQuestAmount > 0 {
//            self.currentQuestIndex = (self.tavernQuestAmount - 1)
//        } else {
//            self.currentQuestIndex = 0
//        }
        // We set this to 2 because of 1 download operation and 1 update operation
        self.operationQueue.maxConcurrentOperationCount = 2
    }
    
    public func initDisplatchSequence(completionHandler: QueueDispatcherCompletionHandler?) {
        self.completionHandler = completionHandler
        let questAmountOperation = DownloadQuestAmountOperation.init(tavernAddress: self.tavernAddress, tokenAddress: self.bananoTokenAddress)
        questAmountOperation.completionBlock = {
            self.tavernQuestAmount = questAmountOperation.questAmount
            if let tavernQuestAmount = self.tavernQuestAmount {
                self.currentQuestIndex = tavernQuestAmount - 1
                self.processNextQuest()
            }
        }
        self.operationQueue.addOperations([questAmountOperation], waitUntilFinished: false)
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
    
    private func processNextQuest() {
        guard let currentQuestIndex = self.currentQuestIndex else {
            self.attempToExecuteCompletionHandler()
            return
        }
        if currentQuestIndex < 0 {
            self.attempToExecuteCompletionHandler()
            return
        }
        
        let downloadQuestOperation = DownloadQuestOperation.init(tavernAddress: self.tavernAddress, tokenAddress: self.bananoTokenAddress, questIndex: currentQuestIndex)
        
        downloadQuestOperation.completionBlock = {
            self.currentQuestIndex = currentQuestIndex - 1
            
            if downloadQuestOperation.finishedSuccesfully {
                if let questDict = downloadQuestOperation.questDict {
                    let updateQuestOperation = UpdateQuestOperation.init(questDict: questDict, questIndex: currentQuestIndex)
                    updateQuestOperation.completionBlock = {
                        self.attempToExecuteCompletionHandler()
                    }
                    self.operationQueue.addOperation(updateQuestOperation)
                }
            }
            self.processNextQuest()
        }
        
        self.operationQueue.addOperations([downloadQuestOperation], waitUntilFinished: false)
    }
}
