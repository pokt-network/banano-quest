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
    var currentWallet: Wallet?
    
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
        
        return isValid
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
        
        //        let colorPickerController = DefaultColorPickerViewController()
        //        colorPickerController.delegate = self
        //        navigationController?.pushViewController(colorPickerController, animated: true)
    }
    
    @IBAction func createQuestButtonPressed(_ sender: Any) {
        if isNewQuestValid() {
            let alertView = requestPassphraseAlertView { (passphrase, error) in
                if error != nil {
                    print("Failed to retrieve passphrase from textfield.")
                }else {
                    do {
                        self.currentWallet = try BananoQuest.getCurrentWallet(passphrase: passphrase ?? "")
                        print("address: \(self.currentWallet?.address ?? "none")")
                    }catch let error as NSError {
                        print("Failed with error: \(error)")
                    }
                }
            }
            
            self.present(alertView, animated: false, completion: nil)
        }else {
            let alertView = self.bananoAlertView(title: "Invalid", message: "Invalid quest, please complete the fields properly.")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
}
