//
//  SingleQuestQueueDispatcher.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public class SingleQuestQueueDispatcher: QueueDispatcherProtocol {
    
    private let operationQueue = OperationQueue.init()
    private let tavernAddress: String
    private let bananoTokenAddress: String
    private let questIndex: Int64
    private var completionHandler: QueueDispatcherCompletionHandler?
    
    public init(tavernAddress: String, bananoTokenAddress: String, questIndex: Int64) {
        self.tavernAddress = tavernAddress
        self.bananoTokenAddress = bananoTokenAddress
        self.questIndex = questIndex
    }
    
    public func initDisplatchSequence(completionHandler: QueueDispatcherCompletionHandler?) {
        self.completionHandler = completionHandler
        if self.questIndex < 0 {
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
            return
        }
        
        let downloadQuestOperation = DownloadQuestOperation.init(tavernAddress: self.tavernAddress, tokenAddress: self.bananoTokenAddress, questIndex: self.questIndex)
        downloadQuestOperation.completionBlock = {
            if downloadQuestOperation.finishedSuccesfully, let questDict = downloadQuestOperation.questDict{
                let updateQuestOperation = UpdateQuestOperation.init(questDict: questDict, questIndex: self.questIndex)
                updateQuestOperation.completionBlock = {
                    self.attempToExecuteCompletionHandler()
                }
                self.operationQueue.addOperation(updateQuestOperation)
            } else {
                self.attempToExecuteCompletionHandler()
            }
        }
        self.operationQueue.addOperation(downloadQuestOperation)
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
}
