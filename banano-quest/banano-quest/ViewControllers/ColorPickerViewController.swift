//
//  ColorPickerViewController.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 7/10/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import FlexColorPicker

class ColorPickerViewController: CustomColorPickerViewController {
    @IBOutlet weak var colorPickerView: RadialPaletteControl! {
        didSet {
            colorPicker.controlDidSet(newValue: colorPickerView, oldValue: oldValue)
        }
    }
    
    @IBOutlet weak var colorPreviewWithHex: ColorPreviewWithHex! {
        didSet {
            colorPicker.controlDidSet(newValue: colorPreviewWithHex, oldValue: oldValue)
        }
    }
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func refreshView() throws {
        //
    }
    
    // MARK: IBActions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        backButtonPressed(sender)
    }
}
