//
//  AddBalanceViewController.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 8/17/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AddBalanceViewController: UIViewController, WKUIDelegate {
    // Outlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    // Variables
    var player: Player?
    let exchange1URL = URL(string: "https://www.coinbase.com/")
    let exchange2URL = URL(string: "https://changelly.com")
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.uiDelegate = self
        
        if player == nil {
            do {
                player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            } catch let error as NSError {
                print("Failed to retrieve current player with error: \(error)")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }
    
    override func refreshView() throws {
        addressLabel.text = player?.address ?? "0x0000000000000000"
        qrCodeImage.image = generateQRCode(from: player?.address ?? "")
    }
    
    // MARK: Tools
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        if webView.isHidden {
            self.dismiss(animated: false, completion: nil)
        }else {
            webView.isHidden = true
            backButton.layer.borderWidth = 0
        }
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        let showError = {
            let alertView = self.bananoAlertView(title: "Error:", message: "Address field is empty, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
        guard let isAddressEmpty = addressLabel.text?.isEmpty else {
            showError()
            return
        }
        if isAddressEmpty {
            showError()
            return
        } else {
            let alertView = bananoAlertView(title: "Success:", message: "Your Address has been copied to the clipboard.")
            present(alertView, animated: false, completion: nil)
            UIPasteboard.general.string = addressLabel.text
        }
    }
    
    @IBAction func exchange1ButtonPressed(_ sender: Any) {
        webView.isHidden = false
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
        
        let request = URLRequest(url: exchange1URL!)
        webView.load(request)
    }
    
    @IBAction func exchange2ButtonPressed(_ sender: Any) {
        webView.isHidden = false
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
        
        let request = URLRequest(url: exchange2URL!)
        webView.load(request)
    }
    
}