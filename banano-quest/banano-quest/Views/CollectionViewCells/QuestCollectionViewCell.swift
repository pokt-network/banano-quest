//
//  QuestCollectionViewCell.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit

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
        // WINNERS COUNT
        // PRIZE VALUE
        // DISTANCE FROM QUEST
        questNameLabel.text = quest.name
        bananosCountLabel.text = String(quest.maxWinners)
        prizeValueLabel.text = "1.00 USD"
        questDistanceLabel.text = "30M"
        hintTextView.text = quest.hint

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
