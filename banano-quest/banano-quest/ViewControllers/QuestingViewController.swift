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

    var quests: [Quest] = [Quest]()
    var currentIndex = 0
    var locationManager = CLLocationManager()
    var currentPlayerLocation: CLLocation?
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Quest list
        loadQuestList()
        setupLocationManager()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)

        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func refreshView() throws {
        // Every UI refresh should be done here
        if self.quests.isEmpty {
            loadQuestList()
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Tools
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            let alertView = self.bananoAlertView(title: "Error", message: "Location services are disabled, please enable for a better questing experience")
            self.present(alertView, animated: false, completion: nil)
        }
    }

    func loadQuestList() {
        // Initial load for the local quest list
        do {
            self.quests = try Quest.sortedQuestsByIndex(context: CoreDataUtils.mainPersistentContext)
            if self.quests.count == 0 {
                DispatchQueue.main.async {
                    self.showElements(bool: true)
                    let label = self.showLabelWith(message: "No Quests available, please try again later...")
                    self.view.addSubview(label)
                }
            } else {
                self.showElements(bool: false)
                do {
                    try self.refreshView()
                }catch let error as NSError {
                    print("Failed to refreshView with error: \(error)")
                }
            }
        } catch {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve quest list with error:")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve quest list with error: \(error)")
        }
    }

    func showElements(bool: Bool) {
        DispatchQueue.main.async {
            self.collectionView.isHidden = bool
            self.previousButton.isHidden = bool
            self.nextButton.isHidden = bool
            self.completeButton.isHidden = bool
        }
    }

    func scrollToPositionedCell(positions: Int) {
        if let currentVisibleCell = self.collectionView.visibleCells.first {
            guard let cellIndexPath = self.collectionView.indexPath(for: currentVisibleCell) else {
                return
            }
            let currentQuestCount = self.quests.count
            let newIndex = cellIndexPath.item + positions
            if newIndex >= 0 && newIndex < currentQuestCount {
                let newIndexPath = IndexPath(item: newIndex, section: 0)
                collectionView.scrollToItem(at: newIndexPath, at: .right, animated: true)
            }
        }
    }
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location update
        if locations.count > 0 {
            guard let location = locations.last else {
                return
            }
            self.currentPlayerLocation = location
            do {
                try self.refreshView()
            }catch let error as NSError {
                print("Failed to refreshView with error: \(error)")
            }
        } else {
            let alertView = self.bananoAlertView(title: "Error", message: "Failed to get current location.")
            self.present(alertView, animated: false, completion: nil)

            print("Failed to get current location")
        }
    }
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        completeButtonPressed(self)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quests.count == 0 ? 1 : quests.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 10
        let height = collectionView.frame.height

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questCollectionViewIdentifier", for: indexPath) as! QuestCollectionViewCell

        currentIndex = indexPath.item

        if quests.isEmpty || currentIndex >= quests.count {
            cell.configureEmptyCell()
            return cell
        }

        let quest = quests[currentIndex]
        cell.quest = quest
        cell.configureCell(playerLocation: self.currentPlayerLocation)

        return cell
    }
    
    // MARK: IBActions
    @IBAction func nextButtonPressed(_ sender: Any) {
        scrollToPositionedCell(positions: 1)
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        scrollToPositionedCell(positions: -1)
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
        guard let currentCell = collectionView.visibleCells.last as? QuestCollectionViewCell else {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve current quest, please try again later.")
            self.present(alert, animated: false, completion: nil)
            
            print("Failed to retrieve current quest, returning")
            return
        }

        if let quest = currentCell.quest {
            do {
                let vc = try self.instantiateViewController(identifier: "completeQuestViewControllerID", storyboardName: "Questing") as? CompleteQuestViewController
                vc?.quest = quest

                self.present(vc!, animated: false, completion: nil)
            }catch let error as NSError {
                let alert = self.bananoAlertView(title: "Error", message: "Ups, something happened, please try again later.")
                self.present(alert, animated: false, completion: nil)

                print("Failed to instantiate NewWalletViewController with error: \(error)")
            }
        } else {
            let alert = self.bananoAlertView(title: "Error", message: "Failed to retrieve current quest, please try again later.")
            self.present(alert, animated: false, completion: nil)
        }
    }
}
