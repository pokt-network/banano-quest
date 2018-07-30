//
//  ContainerViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/6/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import SidebarOverlay

class ContainerViewController: SOContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuSide = .left
        self.topViewController = self.storyboard?.instantiateViewController(withIdentifier: "QuestingVC")
        self.sideViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuVC")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func refreshView() throws {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
