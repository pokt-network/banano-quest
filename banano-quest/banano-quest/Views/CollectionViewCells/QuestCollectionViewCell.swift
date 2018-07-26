//
//  QuestCollectionViewCell.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import SwiftHEXColors
import MapKit

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
    
    func configureCell(quest: Quest, playerLocation: CLLocation?) {
        // TODO:
        // PRIZE VALUE
        // DISTANCE FROM QUEST
        questNameLabel.text = quest.name
        if quest.maxWinners == "0" {
            bananosCountLabel.text = "INFINITE"
            bananosCountLabel.font = bananosCountLabel.font.withSize(14)
        } else {
            bananosCountLabel.text = "\(quest.winnersAmount)/\(quest.maxWinners)"
            bananosCountLabel.font = bananosCountLabel.font.withSize(17)
        }
        if quest.prize == "0" {
            prizeValueLabel.text = "No ETH"
        } else {
            prizeValueLabel.text = "\(quest.prize) ETH"
        }
        
        if let playerLocation = playerLocation {
            let distanceMeters = LocationUtils.questDistanceToPlayerLocation(quest: quest, playerLocation: playerLocation).magnitude
            let roundedDistanceMeters = Double(round(10*distanceMeters)/10)
            var distanceText = "?"

            if roundedDistanceMeters > 999 {
                let roundedDistanceKM = roundedDistanceMeters/1000
                if roundedDistanceKM > 999 {
                    distanceText = String.init(format: "%.1fK KM", (roundedDistanceKM/1000))
                } else {
                    distanceText = String.init(format: "%.1f KM", (roundedDistanceKM/1000))
                }
            } else {
                distanceText = String.init(format: "%.1f M", roundedDistanceMeters)
            }
            
            questDistanceLabel.text = distanceText
        } else {
            questDistanceLabel.text = "?"
        }
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
