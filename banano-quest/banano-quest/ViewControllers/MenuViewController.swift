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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

