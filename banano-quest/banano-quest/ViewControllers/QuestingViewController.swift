//
//  QuestingViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import Pocket
import MapKit

class QuestingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    var quests: [Quest]?
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Quest list
        loadQuestList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
    
        refreshView()
    }
    
    func loadQuestList() {
        // Initial load for the local quest list
        do {
            try Quest.retrieveQuestList { (questList, error) in
                self.quests = questList
                
                if self.quests?.count == 0 {
                    DispatchQueue.main.async {
                        self.hideElements(bool: true)
                        let label = self.showLabelWith(message: "No Quests available, please try again later...")
                        self.view.addSubview(label)
                    }
                }else {
                    self.hideElements(bool: false)
                    self.refreshView()
                }
            }
        }catch let error as NSError{
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve quest list with error: \(error)")
        }
    }

    func refreshView() {
        // Every UI refresh should be done here
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func hideElements(bool: Bool) {
        DispatchQueue.main.async {
            self.collectionView.isHidden = bool
            self.previousButton.isHidden = bool
            self.nextButton.isHidden = bool
            self.completeButton.isHidden = bool
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if currentIndex + 1 < quests?.count ?? 0 {
            currentIndex = currentIndex + 1
            let indexPath = IndexPath(item: currentIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            print("Moving to next")
        }else{
            print("Failed to move next")
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        if quests?.count ?? 0 > 0 {
            if currentIndex - 1 > 0 {
                currentIndex = currentIndex - 1
                let indexPath = IndexPath(item: currentIndex, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                print("Moving to previous")
            } else{
                print("Previous index > 0")
            }
        }else{
            print("Failed to move previous")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quests?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 10
        let height = collectionView.frame.height
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questCollectionViewIdentifier", for: indexPath) as! QuestCollectionViewCell
        
        guard let quest = quests?[indexPath.item] else {
            cell.configureEmptyCell()
            return cell
        }
        currentIndex = indexPath.item
        
        cell.configureCell(quest: quest)
        
        return cell
    }
    @IBAction func menuButtonPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        print("Back to QuestingViewController")
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        guard let quest = quests?[currentIndex] else {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve current quest, please try again later.")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve current quest, returning")
            return
        }
        
        do {
            let vc = try self.instantiateViewController(identifier: "completeQuestViewControllerID", storyboardName: "Questing") as? CompleteQuestViewController
            vc?.quest = quest
            
            self.navigationController?.pushViewController(vc!, animated: false)
        }catch let error as NSError {
            let alert = self.bananoAlertView(title: "Error", message: "Ups, something happened, please try again later.")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to instantiate NewWalletViewController with error: \(error)")
        }
    }
}
