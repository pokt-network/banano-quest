//
//  HowToPlayViewController.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 10/16/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class HowToPlayViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = URLRequest(url: URL(string: "https://bananoquest.com/how-to-play/")!)
        webView.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        do {
            let vc = try self.instantiateViewController(identifier: "QuestingVC", storyboardName: "Questing") as? QuestingViewController
            self.so_containerViewController?.topViewController = vc
        } catch let error as NSError {
            print("Failed to instantiate QuestingViewController with error: \(error)")
        }
    }
}
