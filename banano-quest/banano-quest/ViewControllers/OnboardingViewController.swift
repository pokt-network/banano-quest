//
//  OnboardingViewController.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit

public typealias OnboardingCompletionHandler = () -> Void

class OnboardingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView?
    let searchIdentifier = "Search"
    let findIdentifier = "Find"
    let claimIdentifier = "Claim"
    public var completionHandler: OnboardingCompletionHandler?
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("\(indexPath)")
        var identifier = searchIdentifier
        
        switch Int(indexPath.item) {
        case 0:
            identifier = searchIdentifier
        case 1:
            identifier = findIdentifier
        case 2:
            identifier = claimIdentifier
        default:
            identifier = searchIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onboardingCompleted(_ sender: Any) {
        AppConfiguration.setDisplayedOnboarding(displayedOnboarding: true)
        if let completionHandler = self.completionHandler {
            completionHandler()
        }
    }
    
    override func refreshView() throws {
        
    }
    
}
