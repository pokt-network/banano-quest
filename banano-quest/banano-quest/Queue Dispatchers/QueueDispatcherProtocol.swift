//
//  QueueDispatcherProtocol.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation

public typealias QueueDispatcherCompletionHandler = () -> Void

public protocol QueueDispatcherProtocol {
    
    func initDispatchSequence(completionHandler: QueueDispatcherCompletionHandler?)
    func isQueueFinished() -> Bool
    func cancelAllOperations()
}
