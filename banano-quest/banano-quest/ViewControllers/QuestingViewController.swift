//
//  QuestingViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import Pocket

class QuestingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var bananosLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var quests: [Quest]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Quest list
        loadQuestList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView()
    }
    
    func loadQuestList() {
        // Initial load for the local quest list
        do {
            try Quest.retrieveQuestList { (questList, error) in
                self.quests = questList
                self.refreshView()
            }
        }catch let error as NSError{
            print("Failed to retrieve quest list with error: \(error)")
        }
    }
    
    func refreshView() {
        // Every UI refresh should be done here
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quests?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questCollectionViewIdentifier", for: indexPath) as! QuestCollectionViewCell
        
        guard let quest = quests?[indexPath.item] else {
            cell.configureEmptyCell()
            return cell
        }
        
        cell.configureCell(quest: quest)
        
        return cell
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        print("IM BACK")
    }

}
