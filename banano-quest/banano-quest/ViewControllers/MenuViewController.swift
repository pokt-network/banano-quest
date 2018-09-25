//
//  MenuViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/6/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
