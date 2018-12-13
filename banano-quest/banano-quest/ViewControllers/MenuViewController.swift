//
//  MenuViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/6/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var exploreLabel: UILabel!
    @IBOutlet weak var createQuestLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var howToPlayLabel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Gesture for labels tap
        let exploreGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.exploreButtonTapped(_:)))
        let createQuestGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.createQuestButtonTapped(_:)))
        let profileGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.profileButtonTapped(_:)))
        let howToPlayGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(self.howToPlayButtonTapped(_:)))
        
        exploreGestureRecognizer.delegate = self
        createQuestGestureRecognizer.delegate = self
        profileGestureRecognizer.delegate = self
        howToPlayGestureRecognizer.delegate = self
        
        exploreLabel.addGestureRecognizer(exploreGestureRecognizer)
        createQuestLabel.addGestureRecognizer(createQuestGestureRecognizer)
        profileLabel.addGestureRecognizer(profileGestureRecognizer)
        howToPlayLabel.addGestureRecognizer(howToPlayGestureRecognizer)
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func howToPlayButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "howToPlayViewControllerID", storyboardName: "Help") as? HowToPlayViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate HowToPlayViewController with error: \(error)")
        }
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "QuestingVC", storyboardName: "Questing") as? QuestingViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
    }
    
    @IBAction func createQuestButtonTapped(_ sender: Any) {
        
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "CreateQuestVC", storyboardName: "CreateQuest") as? CreateQuestViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
        
    }
    
    @IBAction func leaderBoardButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "LeaderboardVC", storyboardName: "Leaderboard") as? LeaderboardViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate LeaderboardViewController with error: \(error)")
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = false
        }
        do {
            let vc = try self.instantiateViewController(identifier: "ProfileVC", storyboardName: "Profile") as? ProfileViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
        
    }
    
    override func refreshView() throws {
        
    }
    
}
