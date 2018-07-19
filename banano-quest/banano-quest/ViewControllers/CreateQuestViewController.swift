//
//  CreateQuestViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/2/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import FlexColorPicker
import Pocket
import MapKit

class CreateQuestViewController: UIViewController, ColorPickerDelegate {
    // UI Elements
    @IBOutlet weak var addColorButton: UIButton!
    @IBOutlet weak var addColorView: UIView!
    @IBOutlet weak var questNameTextField: UITextField!
    @IBOutlet weak var prizeAmountUSDTextField: UITextField!
    @IBOutlet weak var prizeAmountETHTextField: UITextField!
    @IBOutlet weak var howManyBananosTextField: UITextField!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var isTherePrizeSwitch: UISwitch!
    @IBOutlet weak var hintTextCountLabel: UILabel!
    @IBOutlet weak var currentUSDBalanceLabel: UILabel!
    @IBOutlet weak var currentETHBalanceLabel: UILabel!
    @IBOutlet weak var gasCostUSDLabel: UILabel!
    @IBOutlet weak var gasCostETHLabel: UILabel!
    
    // Variables
    var newQuest: Quest?
    var selectedLocation = [AnyHashable: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Initial Quest setup
        do {
            try newQuest = Quest(obj: [AnyHashable : Any](), metadata: [AnyHashable : Any](), context: BaseUtil.mainContext)
        } catch let error as NSError {
            print("Failed to create quest with error: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // UI Settings
        addColorButton.layer.cornerRadius = addColorButton.frame.size.width / 2
        addColorButton.clipsToBounds = true
        
        hintTextView.layer.borderWidth = 2.0
        hintTextView.layer.cornerRadius = 5
        hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
        
        // Prize switch toggle action
        isTherePrizeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        
        // Prize is enabled by default
        isPrizeEnabled(bool: true)
        
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapOutside)
    }
    // MARK: - Tools
    
    func isNewQuestValid() -> Bool {
        var isValid = true
        
        if !(questNameTextField.text ?? "").isEmpty {
            newQuest?.name = questNameTextField.text
        }else {
            isValid = false
            return isValid
        }
        if !(howManyBananosTextField.text ?? "0.0").isEmpty {
            newQuest?.maxWinners = Int16(howManyBananosTextField.text ?? "0") ?? 0
        }else {
            isValid = false
            return isValid
        }
        // TODO: PRIZE
        if !(prizeAmountETHTextField.text ?? "0.0").isEmpty {
            newQuest?.prize = Double(prizeAmountETHTextField.text ?? "0.0") ?? 0.0
        }else {
            isValid = false
            return isValid
        }
        if !(hintTextView.text ?? "").isEmpty {
            newQuest?.hint = hintTextView.text
        }else {
            isValid = false
            return isValid
        }
        if newQuest?.metadata?.hexColor == nil {
            isValid = false
            return isValid
        }
        // Setup merkleTree
        setupMerkleTree()
        
        if newQuest?.merkleRoot?.isEmpty ?? false {
            isValid = false
            return isValid
        }
        if newQuest?.merkleBody?.isEmpty ?? false {
            isValid = false
            return isValid
        }
        
        return isValid
    }
    
    func createNewQuest() {
        // New Quest submission
        // TODO: //
    }
    
    func setupMerkleTree() {
        if !(selectedLocation["lat"] as! String).isEmpty && !(selectedLocation["lon"] as! String).isEmpty{
            let latitude = CLLocationDegrees.init(selectedLocation["lat"] as! Double)
            let longitude = CLLocationDegrees.init(selectedLocation["lon"] as! Double)
            
            let location = CLLocation.init(latitude: latitude, longitude: longitude)
            let questMerkleTree = QuestMerkleTree.init(questCenter: location )
            // TODO: merkleRoot == rootHex ? ? ?
            newQuest?.merkleBody = questMerkleTree.getMerkleBody()
            newQuest?.merkleRoot = questMerkleTree.getRootHex()
        }else {
            let alertView = bananoAlertView(title: "Error", message: "Failed to process the selected location, please try again later")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
    func isPrizeEnabled(bool: Bool) {
        // Enables/Disables prize text field
        prizeAmountETHTextField.isEnabled = bool
    }
    
    @objc func switchChanged(switchButton: UISwitch) {
        // Checks if the button is On or Off to disable/enable prize textFields
        if switchButton.isOn {
            isPrizeEnabled(bool: true)
        }else {
            isPrizeEnabled(bool: false)
        }
    }
    
    // MARK: - colorPicker
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        addColorView.backgroundColor = selectedColor
        
        if newQuest != nil {
            newQuest?.metadata?.hexColor = selectedColor.hexValue()
        }else {
            // If newQuest is nil, create a new one and assign the new hexColor
            do {
                var metadata = [AnyHashable : Any]()
                metadata["hexColor"] = selectedColor.hexValue()
                
                try newQuest = Quest(obj: [AnyHashable : Any](), metadata: metadata, context: BaseUtil.mainContext)
            } catch let error as NSError {
                print("Failed to create quest with error: \(error)")
            }
        }
    }
    
    func colorPicker(_ colorPicker: ColorPickerController, confirmedColor: UIColor, usingControl: ColorControl) {
        print("Confirmed a color")
    }
    
    // MARK: - IBActions
    @IBAction func menuPressed(_ sender: Any) {
        if let container = self.so_containerViewController {
            container.isSideViewControllerPresented = true
        }
    }
    @IBAction func addColorPressed(_ sender: Any) {
        do {
            let colorPickerController = try self.instantiateViewController(identifier: "colorPickerViewControllerID", storyboardName: "CreateQuest") as! ColorPickerViewController
            
            colorPickerController.delegate = self
            present(colorPickerController, animated: true, completion: nil)
            
        } catch let error as NSError {
            print("failed: \(error)")
        }
        
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        do {
            let mapVC = try instantiateViewController(identifier: "createQuestMapViewControllerID", storyboardName: "CreateQuest")
            
            present(mapVC, animated: false, completion: nil)
        } catch let error as NSError {
            print("Failed to instantiate CreateQuestMapViewController with error: \(error)")
        }
        
    }
    
    @IBAction func createQuestButtonPressed(_ sender: Any) {
        // Check if the quest inputs are correct.
        if isNewQuestValid(){
            // If current wallet is already unlocked, create new quest
            if BananoQuest.currentWallet != nil {
                createNewQuest()
            }else {
                // Prompt passphrase input to unlock wallet
                let alertView = requestPassphraseAlertView { (passphrase, error) in
                    if error != nil {
                        // Show alertView for error if passphrase is nil
                        let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve passphrase from textfield.")
                        self.present(alertView, animated: false, completion: nil)
                    }else {
                        // Retrieve wallet with passphrase
                        do {
                            BananoQuest.currentWallet = try BananoQuest.getCurrentWallet(passphrase: passphrase ?? "")
                            self.createNewQuest()
                        }catch let error as NSError {
                            let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve account with passphrase, please try again later.")
                            self.present(alertView, animated: false, completion: nil)
                            print("Failed with error: \(error)")
                        }
                    }
                }
                
                self.present(alertView, animated: false, completion: nil)
            }
            
        }else {
            let alertView = self.bananoAlertView(title: "Invalid", message: "Invalid quest, please complete the fields properly.")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
}
