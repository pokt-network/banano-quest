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
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var bananoImageBackground: UIImageView!
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
    
    // Notifications
    static let notificationName = Notification.Name("getLocation")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Initial Quest setup
        do {
            try newQuest = Quest(obj: [AnyHashable : Any](), metadata: [AnyHashable : Any](), context: BaseUtil.mainContext)
        } catch let error as NSError {
            print("Failed to create quest with error: \(error)")
        }
        
        // Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CreateQuestViewController.notificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // UI Settings
        defaultUIElementsStyle()
        
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
    @objc func onNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            selectedLocation = notification.userInfo ?? [AnyHashable: Any]()
        }
    }
    
    func defaultUIElementsStyle() {
        addColorButton.layer.cornerRadius = addColorButton.frame.size.width / 2
        addColorButton.layer.borderWidth = 1
        addColorButton.layer.borderColor = UIColor.clear.cgColor
        addColorButton.clipsToBounds = true
        
        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = UIColor.clear.cgColor
        
        questNameTextField.layer.borderWidth = 1
        questNameTextField.layer.borderColor = UIColor.clear.cgColor
        
        prizeAmountETHTextField.layer.borderWidth = 1
        prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor
        
        howManyBananosTextField.layer.borderWidth = 1
        howManyBananosTextField.layer.borderColor = UIColor.clear.cgColor
        
        hintTextView.layer.borderWidth = 2.0
        hintTextView.layer.cornerRadius = 5
        hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
        
    }
    
    func enableElements(bool: Bool) {
        addLocationButton.isEnabled = bool
        addColorButton.isEnabled = bool
        questNameTextField.isEnabled = bool
        prizeAmountETHTextField.isEnabled = bool
        isTherePrizeSwitch.isEnabled = bool
        hintTextView.isEditable = bool
        
    }
    
    func isNewQuestValid() -> Bool {
        var isValid = [Bool]()
        
        if (questNameTextField.text ?? "").isEmpty {
            questNameTextField.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            questNameTextField.layer.borderColor = UIColor.clear.cgColor
            newQuest?.name = questNameTextField.text
        }
        if (howManyBananosTextField.text ?? "0.0").isEmpty {
            howManyBananosTextField.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            howManyBananosTextField.layer.borderColor = UIColor.clear.cgColor
            newQuest?.maxWinners = Int64(howManyBananosTextField.text ?? "0") ?? 0
            
        }
        // TODO: PRIZE value in USD api
        if isTherePrizeSwitch.isOn {
            if (prizeAmountETHTextField.text ?? "0.0").isEmpty {
                prizeAmountETHTextField.layer.borderColor = UIColor.red.cgColor
                isValid.append(false)
            }else {
                prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor
                newQuest?.prize = Double(prizeAmountETHTextField.text ?? "0.0") ?? 0.0
            }
        }

        if (hintTextView.text ?? "").isEmpty || hintTextView.text == "HINT GOES HERE" {
            hintTextView.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
            newQuest?.hint = hintTextView.text
        }
        if newQuest?.metadata?.hexColor == nil {
            addColorButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            addColorButton.layer.borderColor = UIColor.clear.cgColor
        }
        
        // Setup merkleTree
        setupMerkleTree()
        
        if newQuest?.merkleRoot?.isEmpty ?? false || newQuest?.merkleRoot == nil {
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        if newQuest?.merkleBody?.isEmpty ?? false || newQuest?.merkleBody == nil{
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        
        if isValid.contains(false) {
            return false
        }else {
            return true
        }
    }
    func presentQuestListView() {
        do {
            let vc = try self.instantiateViewController(identifier: "QuestingVC", storyboardName: "Questing") as! QuestingViewController

            self.present(vc, animated: false, completion: nil)
        }catch {
            let failedAlertView = self.bananoAlertView(title: "Error:", message: "Oops something didn't happen, please try again")
            self.present(failedAlertView, animated: false, completion: nil)
        }
    }
    func createNewQuest() {
        // New Quest submission
        // TODO: assign the questID based on the tavern contract quest count + 1
        do {
            newQuest?.questID = try newQuest?.getLocalQuestCount(context: BaseUtil.mainContext) ?? 0 + 1
        } catch let error as NSError {
            print("Failed to create quest with error: \(error)")
            return
        }
        do {
            try newQuest?.save()
            print("New quest: \(newQuest!)")
            enableElements(bool: false)
            
            let alertView = UIAlertController(title: "Success", message: "Quest created successfully", preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                self.presentQuestListView()
            }))
            present(alertView, animated: false, completion: nil)
        } catch let error as NSError {
            let failedAlertView = self.bananoAlertView(title: "Failed", message: "Failed to create the new quest, please try again later")
            failedAlertView.addAction(UIAlertAction(title: "Try again", style: .default, handler: { (UIAlertAction) in
                self.enableElements(bool: true)
            }))
            self.present(failedAlertView, animated: false, completion: nil)
            print("Failed to save wallet with error: \(error)")
        }
        
    }
    
    func setupMerkleTree() {
        if selectedLocation.count < 2 {
            return
        }
        
        if !(selectedLocation["lat"] as! String).isEmpty && !(selectedLocation["lon"] as! String).isEmpty {
            let latitude = CLLocationDegrees.init(Double(selectedLocation["lat"] as! String) ?? 0.0)
            let longitude = CLLocationDegrees.init(Double(selectedLocation["lon"] as! String) ?? 0.0)
            
            let location = CLLocation.init(latitude: latitude, longitude: longitude)
            let questMerkleTree = QuestMerkleTree.init(questCenter: location )
            
            // Assign properties
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
