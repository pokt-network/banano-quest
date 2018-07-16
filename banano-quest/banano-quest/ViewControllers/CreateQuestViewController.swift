//
//  CreateQuestViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/2/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import FlexColorPicker

class CreateQuestViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    override func viewWillAppear(_ animated: Bool) {
        // UI Settings
        addColorView.layer.cornerRadius = addColorView.frame.size.width / 2
        addColorView.clipsToBounds = true
        
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
    
    @objc func switchChanged(switchButton: UISwitch) {
        // Checks if the button is On or Off to disable/enable prize textFields
        if switchButton.isOn {
            isPrizeEnabled(bool: true)
        }else {
            isPrizeEnabled(bool: false)
        }
    }
    
    func isPrizeEnabled(bool: Bool) {
        // Enables/Disables prize text fields
        prizeAmountETHTextField.isEnabled = bool
        prizeAmountUSDTextField.isEnabled = bool
    }
    
    @IBAction func addColorPressed(_ sender: Any) {
        
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        
//        let colorPickerController = DefaultColorPickerViewController()
//        colorPickerController.delegate = self
//        navigationController?.pushViewController(colorPickerController, animated: true)
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
