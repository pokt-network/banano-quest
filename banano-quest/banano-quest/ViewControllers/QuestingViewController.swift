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

class QuestingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var quests: [Quest]?
    var currentIndex = 0
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        // Checks is location services are enabled to start updating location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        }else{
            print("Location services are disabled, please enable before trying again.")
        }
        
        // Quest list
        loadQuestList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Looks for single or multiple taps.
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        view.addGestureRecognizer(tapOutside)
        
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if currentIndex + 1 < quests?.count ?? 0 {
            currentIndex = currentIndex + 1
            let indexPath = IndexPath(item: currentIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        if quests?.count ?? 0 > 0 {
            if currentIndex - 1 > 0 {
                currentIndex = currentIndex - 1
                let indexPath = IndexPath(item: currentIndex, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quests?.count ?? 1
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
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        print("IM BACK")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // TODO: Update authorize/denied location access flow
        }
    }
}
