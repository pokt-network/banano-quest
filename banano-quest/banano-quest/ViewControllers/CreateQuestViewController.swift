//
//  CreateQuestViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/2/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import UIKit
import FlexColorPicker
import Pocket
import MapKit
import BigInt

class CreateQuestViewController: UIViewController, ColorPickerDelegate, UITextViewDelegate {
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
    @IBOutlet weak var infiniteBananosSwitch: UISwitch!
    @IBOutlet weak var hintTextCountLabel: UILabel!
    @IBOutlet weak var currentUSDBalanceLabel: UILabel!
    @IBOutlet weak var currentETHBalanceLabel: UILabel!
    @IBOutlet weak var gasCostUSDLabel: UILabel!
    @IBOutlet weak var gasCostETHLabel: UILabel!

    // Variables
    var newQuest: Quest?
    var currentPlayer: Player?
    var currentWallet: Wallet?
    var selectedLocation = [AnyHashable: Any]()
    
    // Constants
    let maxHintSize = 280

    // Notifications
    static let notificationName = Notification.Name("getLocation")

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial Quest setup
        do {
            newQuest = try Quest.init(obj: [:], context: CoreDataUtils.mainPersistentContext)
        } catch let error as NSError {
            print("Failed to create quest with error: \(error)")
        }
        // Get current player
        do {
            currentPlayer = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("Failed to retrieve current player")
        }

        // Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CreateQuestViewController.notificationName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }

    override func refreshView() throws {
        // UI Settings
        defaultUIElementsStyle()

        // Set current player balance
        refreshPlayerBalance()
    }

    // MARK: - Tools
    func retrieveGasEstimate(handler: @escaping (BigInt?) -> Void) {
        let prizeStr = newQuest?.prize! ?? "0.0"
        let questPrize = BigInt.init(prizeStr) ?? BigInt.init(0)
        let operationQueue = OperationQueue.init()
        let gasEstimateOperation = UploadQuestEstimateOperation.init(playerAddress: (currentPlayer?.address)!, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questName: (newQuest?.name)!, hint: (newQuest?.hint)!, maxWinners: BigInt.init((newQuest?.maxWinners)!)!, merkleRoot: (newQuest?.merkleRoot)!, merkleBody: (newQuest?.merkleBody)!, metadata: setupMetadata()!, ethPrizeWei: questPrize)
        
        gasEstimateOperation.completionBlock = {
            handler(gasEstimateOperation.estimatedGasWei)
        }
        operationQueue.addOperations([gasEstimateOperation], waitUntilFinished: false)
    }
    
    func refreshPlayerBalance() {
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            let playerBalanceStr = player.balanceWei
            guard let playerBalanceBigInt = BigInt.init(playerBalanceStr) else {
                blankBalanceLabels()
                return
            }
            setCurrentUSDBalanceLabel(amount: EthUtils.convertWeiToUSD(wei: playerBalanceBigInt))
            setCurrentETHBalanceLabel(amount: EthUtils.convertWeiToEth(wei: playerBalanceBigInt))
        } catch {
            blankBalanceLabels()
        }
    }

    func blankBalanceLabels() {
        self.currentUSDBalanceLabel.text = "0.0 USD"
        self.currentETHBalanceLabel.text = "0.0 ETH"
    }

    func setCurrentUSDBalanceLabel(amount: Double) {
        self.currentUSDBalanceLabel.text = String.init(format: "%.2f USD", amount)
    }

    func setCurrentETHBalanceLabel(amount: Double) {
        self.currentETHBalanceLabel.text = String.init(format: "%.2f ETH", amount)
    }

    @objc func onNotification(notification:Notification)
    {
        if notification.userInfo != nil {
            selectedLocation = notification.userInfo ?? [AnyHashable: Any]()
        }
    }

    func defaultUIElementsStyle() {
        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false
        view.addGestureRecognizer(tapOutside)
        
        bananoImageBackground.layer.cornerRadius = bananoImageBackground.frame.size.width / 2
        
        infiniteBananosSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        
        addColorButton.layer.cornerRadius = addColorButton.frame.size.width / 2
        addColorButton.layer.borderWidth = 1
        addColorButton.layer.borderColor = UIColor.clear.cgColor
        addColorButton.clipsToBounds = true

        addLocationButton.layer.borderWidth = 1
        addLocationButton.layer.borderColor = UIColor.clear.cgColor

        questNameTextField.layer.borderWidth = 1
        questNameTextField.layer.borderColor = UIColor.clear.cgColor

        prizeAmountUSDTextField.addTarget(self, action: #selector(prizeAmountDidChange), for: UIControlEvents.editingChanged)
        
        prizeAmountETHTextField.layer.borderWidth = 1
        prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor

        howManyBananosTextField.layer.borderWidth = 1
        howManyBananosTextField.layer.borderColor = UIColor.clear.cgColor

        hintTextView.delegate = self
        if (hintTextView.text.isEmpty) {
            hintTextView.text = "Insert a clue about where the BANANO will be hidden"
            hintTextView.textColor = UIColor.lightGray
            hintTextView.selectedTextRange = hintTextView.textRange(from: hintTextView.beginningOfDocument, to: hintTextView.beginningOfDocument)
        }
        hintTextView.layer.borderWidth = 2.0
        hintTextView.layer.cornerRadius = 5
        hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
    }

    func enableElements(bool: Bool) {
        addLocationButton.isEnabled = bool
        addColorButton.isEnabled = bool
        questNameTextField.isEnabled = bool
        prizeAmountETHTextField.isEnabled = bool
        infiniteBananosSwitch.isEnabled = bool
        hintTextView.isEditable = bool
    }

    func isNewQuestValid() -> Bool {
        var isValid = [Bool]()
        
        // Validate quest name
        if (questNameTextField.text ?? "").isEmpty {
            questNameTextField.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            questNameTextField.layer.borderColor = UIColor.clear.cgColor
            newQuest?.name = questNameTextField.text ?? ""
        }
        
        // Validate eth prize
        let usdAmount = Double(prizeAmountUSDTextField.text ?? "0.0") ?? 0.0
        let weiAmount = EthUtils.convertEthToWei(eth: EthUtils.convertUSDAmountToEth(usdAmount: usdAmount))
        if usdAmount > 0 {
            if infiniteBananosSwitch.isOn {
                prizeAmountUSDTextField.layer.borderColor = UIColor.red.cgColor
                prizeAmountETHTextField.layer.borderColor = UIColor.red.cgColor
                isValid.append(false)
            } else {
                prizeAmountUSDTextField.layer.borderColor = UIColor.clear.cgColor
                prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor
                newQuest?.prize = String.init(weiAmount)
            }
        } else {
            prizeAmountUSDTextField.layer.borderColor = UIColor.clear.cgColor
            prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor
            newQuest?.prize = String.init(weiAmount)
        }

        // Validate banano amount
        if infiniteBananosSwitch.isOn {
            newQuest?.maxWinners = String.init(BigInt.init(0))
        } else {
            if (howManyBananosTextField.text ?? "0.0").isEmpty {
                howManyBananosTextField.layer.borderColor = UIColor.red.cgColor
                isValid.append(false)
            }else {
                howManyBananosTextField.layer.borderColor = UIColor.clear.cgColor
                newQuest?.maxWinners = String.init(BigInt.init(howManyBananosTextField.text ?? "0") ?? BigInt.init(0))
            }
        }

        // Validate quest hint
        if (hintTextView.text ?? "").isEmpty || hintTextView.text.count > maxHintSize || hintTextView.textColor == UIColor.lightGray {
            hintTextView.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        } else {
            hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
            newQuest?.hint = hintTextView.text
        }
        
        // Validate hex color
        if newQuest?.hexColor == nil {
            addColorButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            addColorButton.layer.borderColor = UIColor.clear.cgColor
        }

        // Setup merkleTree
        setupMerkleTree()

        // Validate merkle tree
        if newQuest?.merkleRoot.isEmpty ?? false || newQuest?.merkleRoot == nil {
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        if newQuest?.merkleBody.isEmpty ?? false || newQuest?.merkleBody == nil{
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        } else {
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }

        // Validate quest metadata
        if setupMetadata() == nil {
            isValid.append(false)
        }
        
        // Return valid response
        return !isValid.contains(false)
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
        // Pepare fields
        let transactionCount = BigInt.init(currentPlayer?.transactionCount ?? "0") ?? BigInt.init(0)
        guard let prizeWei = BigInt.init(newQuest?.prize ?? "0") else {
            return
        }
        guard let maxWinners = BigInt.init(newQuest?.maxWinners ?? "0") else {
            return
        }
        guard let wallet = currentWallet else {
            return
        }
        guard let questName = newQuest?.name else {
            return
        }
        guard let questHint = newQuest?.hint else {
            return
        }
        guard let merkleRoot = newQuest?.merkleRoot else {
            return
        }
        guard let merkleBody = newQuest?.merkleBody else {
            return
        }
        guard let metadata = setupMetadata() else {
            return
        }

        // Upload quest operation
        let operation = UploadQuestOperation.init(wallet: wallet, tavernAddress: AppConfiguration.tavernAddress, tokenAddress: AppConfiguration.bananoTokenAddress, questName: questName, hint: questHint, maxWinners: maxWinners, merkleRoot: merkleRoot, merkleBody: merkleBody, metadata:  metadata, transactionCount: transactionCount, ethPrizeWei: prizeWei)
        operation.completionBlock = {
            UIApplication.getPresentedViewController(handler: { (topVC) in
                if topVC == nil {
                    print("Failed to get current view controller")
                }else {
                    do {
                        try topVC!.refreshView()
                    }catch let error as NSError {
                        print("Failed to refresh current view controller with error: \(error)")
                    }
                }
            })
        }
        // Operation Queue
        let operationQueue = OperationQueue.init()
        operationQueue.addOperations([operation], waitUntilFinished: false)

        // UI Elements disabled
        enableElements(bool: false)

        // Let the user knows and present Quest list
        let alertView = UIAlertController(title: "Success", message: "Quest creation submitted successfully, we will let you know when it's done", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
            self.presentQuestListView()
        }))

        present(alertView, animated: false, completion: nil)
    }

    func setupMetadata() -> String? {
        let hexColorStr: String?
        let hintQuadrant: [CLLocation]?
        var metadataStr: String?

        if newQuest?.hexColor == nil {
            // Generate random hexColor
            newQuest?.hexColor = UIColor.random().hexValue()
        }
        hexColorStr = newQuest?.hexColor

        if selectedLocation.count < 2 {
            return nil
        }

        if !(selectedLocation["lat"] as! String).isEmpty && !(selectedLocation["lon"] as! String).isEmpty {
            let selectedLocation = CLLocation.init(latitude: Double(self.selectedLocation["lat"] as! String) ?? 0.0, longitude: Double(self.selectedLocation["lon"] as! String) ?? 0.0)
            let randomQuadrantCenter = LocationUtils.generateRandomCoordinates(currentLoc: selectedLocation, min: 21, max: 179)
            hintQuadrant = LocationUtils.generateHintQuadrant(center: randomQuadrantCenter, sideDistance: 0.2)
        }else {
            let alertView = bananoAlertView(title: "Error", message: "Failed to process the selected location, please try again later")
            self.present(alertView, animated: false, completion: nil)
            return nil
        }

        // Create metadata string
        if let hexColorStr = hexColorStr, let hintQuadrant = hintQuadrant {
            var metadataArr = [Any]()
            metadataArr.append(hexColorStr)
            metadataArr.append(contentsOf: hintQuadrant)

            metadataStr = metadataArr.reduce(into: String.init(""), { (result, currValue) in
                if let strValue = currValue as? String {
                    result.append(contentsOf: strValue + ",")
                } else if let locValue = currValue as? CLLocation {
                    let currLatStr = String.init(locValue.coordinate.latitude)
                    let currLonStr = String.init(locValue.coordinate.longitude)
                    result.append(contentsOf: currLatStr + ",")
                    result.append(contentsOf: currLonStr + ",")
                }
            })
            // Remove trailing comma
            metadataStr?.removeLast()
        }

        return metadataStr
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
    
    func toggleBananoAmountTextField() {
        howManyBananosTextField.isEnabled = !howManyBananosTextField.isEnabled
    }
    
    // MARK: - Selectors
    @objc func prizeAmountDidChange(textField: UITextField) {
        if textField.text != "0.0" {
            if let usdValue = Double(textField.text ?? "0.0") {
                prizeAmountETHTextField.text = String.init(format: "%.2f", EthUtils.convertUSDAmountToEth(usdAmount: usdValue))
                if self.infiniteBananosSwitch.isOn {
                    howManyBananosTextField.isEnabled = true
                    self.howManyBananosTextField.text = "1"
                    self.infiniteBananosSwitch.isOn = false
                }
            } else {
                prizeAmountETHTextField.text = "0.0"
            }
        } else {
            prizeAmountETHTextField.text = "0.0"
        }
    }

    @objc func switchChanged(switchButton: UISwitch) {
        // Checks if the button is On or Off to disable/enable banano amount textField
        toggleBananoAmountTextField()
        if switchButton.isOn {
            self.howManyBananosTextField.text = ""
            self.prizeAmountUSDTextField.text = "0.0"
            self.prizeAmountDidChange(textField: self.prizeAmountUSDTextField)
        } else {
            self.howManyBananosTextField.text = "1"
        }
    }

    // MARK: - colorPicker
    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
        addColorView.backgroundColor = selectedColor

        if newQuest != nil {
            newQuest?.hexColor = selectedColor.hexValue()
        } else {
            // If newQuest is nil, create a new one and assign the new hexColor
            do {
                var metadata = [AnyHashable : Any]()
                metadata["hexColor"] = selectedColor.hexValue()

                try newQuest = Quest.init(obj: [:], context: CoreDataUtils.mainPersistentContext)
            } catch let error as NSError {
                print("Failed to create quest with error: \(error)")
            }
        }
        self.bananoImageBackground.backgroundColor = selectedColor
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
            self.retrieveGasEstimate { (gasEstimateWei) in
                if let gasEstimate = gasEstimateWei {
                    let questPrizeWei = BigInt.init(self.newQuest?.prize ?? "0.0") ?? BigInt.init(0)
                    let gasEstimateEth = EthUtils.convertWeiToEth(wei: gasEstimate + questPrizeWei)
                    let gasEstimateUSD = EthUtils.convertEthAmountToUSD(ethAmount: gasEstimateEth)
                    let message = String.init(format: "Note that the value you have determined as a prize, if any, will be divided by the number of BANANOS allocated for the Quest, giving each Winner a fraction of the total prize. Banano Quest retains %@ of the total prize as comission. Total transaction cost: %@ USD - %@ ETH. Press OK to create your Quest", "10%", String.init(format: "%.4f", gasEstimateUSD), String.init(format: "%.4f", gasEstimateEth))
                    let txDetailsAlertView = self.bananoAlertView(title: "Transaction Details", message: message) { (uiAlertAction) in
                        guard let player = self.currentPlayer else {
                            self.present(self.bananoAlertView(title: "Error", message: "Player account not found, please try again"), animated: true, completion: nil)
                            return
                        }
                        
                        self.resolvePlayerWalletAuth(player: player, successHandler: { (wallet) in
                            self.currentWallet = wallet
                            self.createNewQuest()
                        }, errorHandler: { (error) in
                             self.present(self.bananoAlertView(title: "Error", message: "An error ocurred accessing your account, please try again"), animated: true, completion: nil)
                        })
                    }
                    self.present(txDetailsAlertView, animated: false, completion: nil)
                } else {
                    let alertView = self.bananoAlertView(title: "Error", message: "Error retrieving the transaction costs, please try again.")
                    self.present(alertView, animated: false, completion: nil)
                }
            }
        }else {
            let alertView = self.bananoAlertView(title: "Invalid", message: "Invalid quest, please complete the fields properly.")
            self.present(alertView, animated: false, completion: nil)
        }
    }
    
    // MARK: - TextViewDelegate
    // Credit: https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = "Insert a clue about where the BANANO will be hidden"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // Update text length indicator
        let textLength = textView.text.count
        hintTextCountLabel.text = String.init(format: "%i/%i", textLength, maxHintSize)
        if textLength > maxHintSize {
            hintTextCountLabel.textColor = UIColor.red
        } else {
            hintTextCountLabel.textColor = UIColor.black
        }
    }
}
