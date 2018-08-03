//
//  QuestMerkleTree.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/17/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import MapKit
import CryptoSwift

struct MatchingMerkleHash {
    var left:String
    var right:String
    var hashIndex:Int
}

public struct QuestProofSubmission {
    var proof:[String]
    var answer:String
    
    public init(answer: String, proof:[String]) {
        self.answer = answer
        self.proof = proof
    }
}

public class QuestMerkleTree: MerkleTree {
    
    public init(questCenter: CLLocation) {
        let elements = LocationUtils.allPossiblePoints(center: questCenter, diameterMT: 0.02, gpsCoordIncrements: 0.0001).map { (currLocation) -> Data in
            if let locData = currLocation.concatenatedMagnitudes().data(using: .utf8) {
                return locData
            } else {
                return Data()
            }
        }
        super.init(elements: elements, hashFunction: { (currElement) -> Data? in
            return currElement.sha3(.keccak256)
        })
    }
    
    // Returns the hex representation of the merkle root
    public func getRootHex() -> String {
        let rootHex = getRoot().toHexString()
        return rootHex.hasPrefix("0x") ? rootHex : "0x" + rootHex
    }
    
    // Custom merkle body, returns all the merkle tree layers except the root and the leaves, reversed.
    // Format is: each layer separated by -, each node on each layer separated by ,
    public func getMerkleBody() -> String {
        var layers = getLayers()
        layers.removeFirst()
        layers.removeLast()
        layers = layers.reversed()
        let layersStrArr = layers.reduce(into: [String]()) { (result, currLayer) in
            let currLayerStr = currLayer.map({ (currNode) -> String in
                return currNode.toHexString()
            })
            result.append(currLayerStr.joined(separator: ","))
        }
        return layersStrArr.joined(separator: "-")
    }
    
    public static func generateQuestProofSubmission(answer: CLLocation, merkleBody: String) -> QuestProofSubmission? {
        // Setup answer points
        var result:QuestProofSubmission?
        let optionalConcatenatedPoints = LocationUtils.allPossiblePoints(center: answer, diameterMT: 0.02, gpsCoordIncrements: 0.0001).map { (currPoint) -> Data? in
            if let concatenated = currPoint.concatenatedMagnitudes().data(using: .utf8)?.sha3(.keccak256) {
                return concatenated
            } else {
                return nil
            }
        }
        var concatenatedPoints = optionalConcatenatedPoints.reduce(into: [Data]()) { (result, optionalData) in
            guard let data = optionalData else {
                return
            }
            result.append(data)
        }
        concatenatedPoints = concatenatedPoints.sorted(by: { (x, y) -> Bool in
            return x.toHexString() < y.toHexString()
        })
        
        let merkleLayers = merkleBody.split(separator: "-").map { (currLayer) -> [String] in
            return currLayer.components(separatedBy: ",").map({ (currHash) -> String in
                return currHash
            })
        }
        var reversedMerkleLayers = [[String]]()
        for arrayIndex in 0..<merkleLayers.count {
            reversedMerkleLayers.append(merkleLayers[(merkleLayers.count - 1) - arrayIndex])
        }
        let deepestLevel = merkleLayers[merkleLayers.count - 1]
        
        // Find the matching nodes
        var nodeMatches = [MatchingMerkleHash]()
        for hash in concatenatedPoints {
            for siblingHash in concatenatedPoints {
                var elemToCompare: Data = Data()
                elemToCompare.append(hash)
                elemToCompare.append(siblingHash)
                elemToCompare = elemToCompare.sha3(.keccak256)
                let elemToCompareStr = elemToCompare.toHexString()
                
                if let deepestLevelIndex = deepestLevel.index(of: elemToCompareStr) {
                    if deepestLevelIndex >= 0 {
                        nodeMatches.append(
                            MatchingMerkleHash.init(
                                left: hash.toHexString(),
                                right: siblingHash.toHexString(),
                                hashIndex: deepestLevelIndex
                            )
                        )
                    }
                }
            }
        }
        
        // Build submission
        var submissions = [QuestProofSubmission]()
        if nodeMatches.count > 0 {
            for match in nodeMatches {
                 var proof = [String]()
                // Create answer
                let answer = "0x" + match.left
                // Append right as first sibling in the proof
                proof.append("0x" + match.right)
                
                // Start going up the tree via this index
                var index = match.hashIndex
                
                for layer in reversedMerkleLayers {
                    let pairIndex = index % 2 == 0 ? index + 1 : index - 1
                    
                    if pairIndex < layer.count {
                        proof.append("0x" + layer[pairIndex])
                    }
                    index = (index / 2) | 0
                }
                submissions.append(QuestProofSubmission.init(answer: answer, proof: proof))
            }
        }
        
        
        return submissions.last
    }
}
