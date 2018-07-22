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

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

extension CLLocation {
    
    public func concatenatedMagnitudes() -> String {
        let latitude = String(format: "%.4f", self.coordinate.latitude)
        let longitude = String(format: "%.4f", self.coordinate.longitude)
        return latitude + longitude
    }
    
}

struct MatchingMerkleHash {
    var left:String
    var right:String
    var leftIndex:Int
    var rightIndex:Int
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
        let elements = QuestMerkleTree.allPossiblePoints(center: questCenter).map { (currLocation) -> Data in
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
                let nodeHex = currNode.toHexString()
                return nodeHex.hasPrefix("0x") ? nodeHex : "0x" + nodeHex
            })
            result.append(currLayerStr.joined(separator: ","))
        }
        return layersStrArr.joined(separator: "-")
    }
    
    public static func generateQuestProofSubmission(answer: CLLocation, merkleBody: String) -> QuestProofSubmission? {
        // Setup
        var result:QuestProofSubmission?
        let pointHashes = QuestMerkleTree.allPossiblePoints(center: answer).map { (currPoint) -> String? in
            if let hexResult = currPoint.concatenatedMagnitudes().data(using: .utf8)?.sha3(.keccak256).toHexString() {
                return hexResult
            } else {
                return nil
            }
        }
        let filteredPointHashes = pointHashes.filter { (currPointHash) -> Bool in
            return currPointHash != nil
        }
        let merkleLayers = merkleBody.split(separator: "-").map { (currLayer) -> [String] in
            return currLayer.components(separatedBy: ",")
        }
        let reversedMerkleLayers = merkleLayers.reversed()
        let deepestLevel = merkleLayers[merkleLayers.count - 1]
        var proof = [String]()
        
        // Get matching leaves
        let nodeMatches = filteredPointHashes.reduce(into: [MatchingMerkleHash]()) { (matchingNodes, pointHash) in
            for siblingPointHash in filteredPointHashes {
                if var hash = pointHash?.data(using: .utf8), let siblingHash = siblingPointHash?.data(using: .utf8) {
                    if (!hash.elementsEqual(siblingHash)) {
                        hash.append(siblingHash)
                        var combinedHash = hash.sha3(.keccak256).toHexString()
                        combinedHash = combinedHash.hasPrefix("0x") ? combinedHash : "0x" + combinedHash
                        if deepestLevel.contains(combinedHash) {
                            matchingNodes.append(
                                MatchingMerkleHash.init(
                                    left: pointHash!,
                                    right: siblingPointHash!,
                                    leftIndex: filteredPointHashes.index(of: pointHash)!,
                                    rightIndex: filteredPointHashes.index(of: siblingPointHash)!
                                )
                            )
                        }
                    }
                }
            }
        }
        
        // Build submission
        if nodeMatches.count > 0 {
            let match = nodeMatches[0]
            // Create answer
            let answer = match.left
            // Append right as first sibling in the proof
            proof.append(match.right)
            
            // Start going up the tree via this index
            var index = match.leftIndex
            
            for layer in reversedMerkleLayers {
                let isRightNode = index % 2
                let pairIndex = isRightNode != 0 ? index - 1 : index + 1
                
                if pairIndex < layer.count {
                    proof.append(layer[pairIndex])
                }
                
                index = (index / 2) | 0
            }
            
            result = QuestProofSubmission.init(answer: answer, proof: proof)
        }
        
        
        return result
    }

    // Internal functions
    private static func allPossiblePoints(center: CLLocation) -> [CLLocation] {
        let coordsIncrement = 0.0001
        let distance = 0.02
        let radius = 6371.0
        let quotient = (distance/radius).radiansToDegrees;
        let lat = center.coordinate.latitude
        let lon = center.coordinate.longitude
        let maxLat = lat + quotient;
        let minLat = lat - quotient;
        let maxLon = lon + quotient;
        let minLon = lon - quotient;
        
        var latList = [CLLocationDegrees]();
        var lonList = [CLLocationDegrees]();
        var currentLat = minLat;
        var currentLon = minLon;
        var coordList = [CLLocation]();
        
        while(currentLat <= maxLat) {
            latList.append(currentLat);
            currentLat += coordsIncrement;
        }
        
        while(currentLon <= maxLon) {
            lonList.append(currentLon);
            currentLon += coordsIncrement;
        }
        
        for latitude in latList {
            for longitude in lonList {
                coordList.append(CLLocation.init(latitude: latitude, longitude: longitude))
            }
        }
        
        return coordList;
    }
}
