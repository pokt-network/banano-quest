//
//  UIViewController+extension.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 7/6/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import Pocket

public typealias PlayerWalletAuthSuccessHandler = (Wallet) -> Void
public typealias PlayerWalletAuthErrorHandler = (Error) -> Void

public enum PlayerWalletAuthError: Error {
    case invalidPassPhrase
    case invalidWallet
    case invalidPlayerAddress
}

public enum UIViewControllerError: Error {
    case refreshViewNotImplemented
}

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

    func bananoAlertView(title: String, message: String, handler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: handler))

        return alert
    }
    
    func bananoAlertView(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        return alert
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func refreshView() throws {
        // Override
        throw UIViewControllerError.refreshViewNotImplemented
    }

    @objc func dismissNotification() {

        if let notificationView = self.view.viewWithTag(252525) {
            notificationView.removeFromSuperview()
        }
    }

    func showNotificationOverlayWith(text: String!) {
        DispatchQueue.main.async {
            // We get the presented View Controller
            UIApplication.getPresentedViewController(handler: { (currentVC) in
                if currentVC == nil {
                    print("UIViewController - showNotificationOverlayWith(), Failed to get current VC, returning")
                }else {
                    // Current VC frame
                    let frame = currentVC!.view.frame
                    // We create the View
                    let view = UIView.init(frame: CGRect(x: 5, y: frame.height - 90, width: frame.width - 10, height: 80))
                    view.tag = 252525
                    view.layer.cornerRadius = 5
                    view.layer.borderWidth = 1
                    view.layer.borderColor = UIColor.darkGray.cgColor
                    view.backgroundColor = UIColor(red: (49/255), green: (170/255), blue: (222/255), alpha: 1)

                    // We create the label
                    let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 80))
                    label.textColor = UIColor.white
                    label.text = text
                    label.textAlignment = .center

                    // Close button
                    let button = UIButton.init(frame: CGRect.init(x: view.frame.width - 27, y: 2, width: 25, height: 25))
                    button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
                    button.layer.cornerRadius = button.frame.width / 2
                    button.setTitle("X", for: UIControlState.normal)
                    button.titleLabel?.textColor = UIColor.black
                    button.titleLabel?.font = UIFont.init(name: "System", size: 12)

                    button.addTarget(self , action: #selector(self.dismissNotification), for: .touchUpInside)
                    // Label is added to the view
                    view.addSubview(label)
                    view.addSubview(button)
                    // View is added to the current view controller
                    currentVC!.view.addSubview(view)
                }
            })
        }
    }
    
    // MARK: - Wallet auth
    func resolvePlayerWalletAuth(player: Player, successHandler: @escaping PlayerWalletAuthSuccessHandler, errorHandler: @escaping PlayerWalletAuthErrorHandler) {
        guard let playerAddress = player.address else {
            errorHandler(PlayerWalletAuthError.invalidPlayerAddress)
            return
        }
        
        // Check wheter or not biometrics is available
        if BiometricsUtils.biometricsAvailable && BiometricsUtils.biometricRecordExists(playerAddress: playerAddress) {
            BiometricsUtils.retrieveWalletWithBiometricAuth(successHandler: successHandler, errorHandler: errorHandler)
        } else {
            let alertView = self.requestPassphraseAlertView { (passPhrase, error) in
                if let error = error {
                    errorHandler(error)
                    return
                }
                
                guard let passPhrase = passPhrase else {
                    errorHandler(PlayerWalletAuthError.invalidPassPhrase)
                    return
                }
                
                do {
                    guard let wallet = try player.getWallet(passphrase: passPhrase) else {
                        errorHandler(PlayerWalletAuthError.invalidWallet)
                        return
                    }
                    successHandler(wallet)
                } catch {
                    errorHandler(error)
                    print("\(error)")
                }
                
            }
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func requestPassphraseAlertView(handler: @escaping passphraseRequestHandler) -> UIAlertController {
        let alert = UIAlertController(title: "Wallet Passphrase", message: "Please input your Wallet's passphrase", preferredStyle: .alert)
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
}
