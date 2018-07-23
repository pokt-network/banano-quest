//
//  QuestCollectionViewCell.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import SwiftHEXColors
class QuestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var questNameLabel: UILabel!
    @IBOutlet weak var bananosCountLabel: UILabel!
    @IBOutlet weak var prizeValueLabel: UILabel!
    @IBOutlet weak var questDistanceLabel: UILabel!
    @IBOutlet weak var bananoBackgroundView: UIImageView!
    @IBOutlet weak var bananoStampImage: UIImageView!
    @IBOutlet weak var hintTextView: UITextView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bananoBackgroundView.layer.cornerRadius = bananoBackgroundView.frame.size.width / 2
        bananoBackgroundView.clipsToBounds = true
    }
    
    func configureCell(quest: Quest) {
        // TODO:
        // PRIZE VALUE
        // DISTANCE FROM QUEST
        questNameLabel.text = quest.name
        bananosCountLabel.text = "\(quest.winnersAmount)/\(quest.maxWinners)"
        prizeValueLabel.text = "\(quest.prize) ETH"
        questDistanceLabel.text = "30M"
        hintTextView.text = quest.hint
        let bananoColor = UIColor(hexString: quest.hexColor ?? "31AADE")
        bananoBackgroundView.backgroundColor = bananoColor

    }
    
    func configureEmptyCell() {
        questNameLabel.text = "NONE"
        bananosCountLabel.text = "0/0"
        prizeValueLabel.text = "0.00 USD"
        questDistanceLabel.text = "0M"
        hintTextView.text = "NONE"
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
    }
}
