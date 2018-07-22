//
//  QuestMerkleTreeTests.swift
//  banano-questTests
//
//  Created by Luis De Leon on 7/22/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import XCTest
import MapKit
@testable import banano_quest

class QuestMerkleTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        let questMerkleTree = QuestMerkleTree.init(questCenter: CLLocation.init(latitude: 40.6892494, longitude: -74.0466891))
        assert(questMerkleTree.getRootHex().count > 0)
    }
    
}

