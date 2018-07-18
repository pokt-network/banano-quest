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
    public typealias passphraseRequestHandler = (_: String?, _: Error?) -> Void

    func instantiateViewController(identifier: String, storyboardName: String) throws -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        
        return vc
    }
    
    func showLabelWith(message: String) ->  UILabel {
        
        let screenBounds = UIScreen.main.bounds
        let frame = CGRect(x: 0, y: screenBounds.size.height / 2, width: screenBounds.size.width, height: 30)
        let label = UILabel(frame: frame)
        
        label.text = message
        label.contentMode = .center
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        
        return label
    }
    
    func bananoAlertView(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        return alert
    }
    
    func requestPassphraseAlertView(handler: @escaping passphraseRequestHandler) -> UIAlertController {
        let alert = UIAlertController(title: "Wallet Passphrase", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Passphrase"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            if let passphraseTextField = alert.textFields?.first {
                handler(passphraseTextField.text, nil)
            }else {
                handler(nil, "Failed to retrieve passphraseTextField" as? Error)
            }
        }))
        
        return alert
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
