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

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

class CreateQuestViewController: UIViewController, ColorPickerDelegate, UITextFieldDelegate, BananoQuestViewController {
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
    var currentPlayer: Player?
    var currentWallet: Wallet?
    var selectedLocation = [AnyHashable: Any]()

    // Notifications
    static let notificationName = Notification.Name("getLocation")

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial Quest setup
        do {
            newQuest = try Quest.init(obj: [:], context: BaseUtil.mainContext)
        } catch let error as NSError {
            print("Failed to create quest with error: \(error)")
        }
        // Get current player
        do {
            currentPlayer = try Player.getPlayer(context: BaseUtil.mainContext)
        } catch {
            print("Failed to retrieve current player")
        }

        // Notification Center
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: CreateQuestViewController.notificationName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        // UI Setup
        bananoImageBackground.layer.cornerRadius = bananoImageBackground.frame.size.width / 2
        prizeAmountETHTextField.delegate = self

        // Prize switch toggle action
        isTherePrizeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)

        // Gesture recognizer that dismiss the keyboard when tapped outside
        let tapOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapOutside.cancelsTouchesInView = false

        view.addGestureRecognizer(tapOutside)

        do {
            try refreshView()
        } catch let error as NSError {
            print("Failed to refresh view with error: \(error)")
        }
    }

    override func refreshView() throws {
        // UI Settings
        defaultUIElementsStyle()

        // Prize is enabled by default
        isPrizeEnabled(bool: true)

        // Set current player balance
        refreshPlayerBalance()
    }

    // MARK: - Tools
    func refreshPlayerBalance() {
        do {
            let player = try Player.getPlayer(context: CoreDataUtil.mainPersistentContext)
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
            newQuest?.name = questNameTextField.text ?? ""
        }
        if (howManyBananosTextField.text ?? "0.0").isEmpty {
            howManyBananosTextField.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            howManyBananosTextField.layer.borderColor = UIColor.clear.cgColor
            newQuest?.maxWinners = String.init(BigInt.init(howManyBananosTextField.text ?? "0") ?? BigInt.init(0))

        }

        if isTherePrizeSwitch.isOn {
            if (prizeAmountETHTextField.text ?? "0.0").isEmpty {
                prizeAmountETHTextField.layer.borderColor = UIColor.red.cgColor
                isValid.append(false)
            }else {
                prizeAmountETHTextField.layer.borderColor = UIColor.clear.cgColor
                let ethAmount = Double(prizeAmountETHTextField.text ?? "0.0") ?? 0.0
                let weiAmount = EthUtils.convertEthToWei(eth: ethAmount)
                newQuest?.prize = String.init(weiAmount)
            }
        }

        if (hintTextView.text ?? "").isEmpty || hintTextView.text == "HINT GOES HERE" {
            hintTextView.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            hintTextView.layer.borderColor = UIColor(red: (253/255), green: (204/255), blue: (48/255), alpha: 1.0).cgColor
            newQuest?.hint = hintTextView.text
        }
        if newQuest?.hexColor == nil {
            addColorButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else {
            addColorButton.layer.borderColor = UIColor.clear.cgColor
        }

        // Setup merkleTree
        setupMerkleTree()

        if newQuest?.merkleRoot.isEmpty ?? false || newQuest?.merkleRoot == nil {
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }
        if newQuest?.merkleBody.isEmpty ?? false || newQuest?.merkleBody == nil{
            addLocationButton.layer.borderColor = UIColor.red.cgColor
            isValid.append(false)
        }else{
            addLocationButton.layer.borderColor = UIColor.clear.cgColor
        }

        if let _ = setupMetadata() {
            isValid.append(true)
        } else {
            isValid.append(false)
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
            let alertViewController: UIAlertController?
            if let txHash = operation.txHash {
                alertViewController = self.bananoAlertView(title: "Success!", message: "Your quest was created succesfully! with Transaction Hash: \(txHash)")
            } else {
                alertViewController = self.bananoAlertView(title: "Error", message: "An error ocurred, please try again.")
            }

            if let alertViewController = alertViewController {
                self.present(alertViewController, animated: true, completion: nil)
            }
        }
        // Operation Queue
        let operationQueue = OperationQueue.init()
        operationQueue.addOperations([operation], waitUntilFinished: false)

        // UI Elements disabled
        enableElements(bool: false)

        // Let the user knows and present Quest list
        let alertView = UIAlertController(title: "Success", message: "Quest creation submitted successfully, we will let you know when it's done :D .", preferredStyle: .alert)
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
            newQuest?.hexColor = selectedColor.hexValue()
        }else {
            // If newQuest is nil, create a new one and assign the new hexColor
            do {
                var metadata = [AnyHashable : Any]()
                metadata["hexColor"] = selectedColor.hexValue()

                //try newQuest = Quest(obj: [AnyHashable : Any](), metadata: metadata, context: BaseUtil.mainContext)
                try newQuest = Quest.init(obj: [:], context: BaseUtil.mainContext)
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
            // Prompt passphrase input to unlock wallet
            let alertView = requestPassphraseAlertView { (passphrase, error) in
                if error != nil {
                    // Show alertView for error if passphrase is nil
                    let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve passphrase from textfield.")
                    self.present(alertView, animated: false, completion: nil)
                }else {
                    // Retrieve wallet with passphrase
                    do {
                        self.currentWallet = try self.currentPlayer?.getWallet(passphrase: passphrase ?? "")
                        self.createNewQuest()
                    }catch let error as NSError {
                        let alertView = self.bananoAlertView(title: "Failed", message: "Failed to retrieve account with passphrase, please try again later.")
                        self.present(alertView, animated: false, completion: nil)
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

    // MARK: - IBActions
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == prizeAmountETHTextField {
            if prizeAmountETHTextField.text != "0.0" {
                if let ethValue = Double(prizeAmountETHTextField.text ?? "0.0") {
                    prizeAmountUSDTextField.text = "\(EthUtils.convertEthAmountToUSD(ethAmount: ethValue))"
                }
            }else{
                prizeAmountUSDTextField.text = "0.0"
            }
        }
    }
}
