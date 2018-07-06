//
//  UIViewController+extension.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/6/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func instantiateViewController(identifier: String, storyboardName: String) throws -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        return vc
    }
    
}
