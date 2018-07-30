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
import BigInt

class QuestCollectionViewCell: UICollectionViewCell {
    
    var quest: Quest?
    
    @IBOutlet weak var questNameLabel: UILabel?
    @IBOutlet weak var bananosCountLabel: UILabel?
    @IBOutlet weak var prizeValueLabel: UILabel?
    @IBOutlet weak var questDistanceLabel: UILabel?
    @IBOutlet weak var bananoBackgroundView: UIImageView?
    @IBOutlet weak var bananoStampImage: UIImageView?
    @IBOutlet weak var hintTextView: UITextView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            bananoBackgroundView.layer.cornerRadius = bananoBackgroundView.frame.size.width / 2
            bananoBackgroundView.clipsToBounds = true
        }
    }
    
    func configureCell(playerLocation: CLLocation?) {
        // TODO:
        // DISTANCE FROM QUEST
        guard let quest = self.quest else {
            self.configureEmptyCell()
            return
        }
        
        if let questNameLabel = self.questNameLabel {
            questNameLabel.text = quest.name
        }
        if quest.maxWinners == "0" {
            if let bananosCountLabel = self.bananosCountLabel {
                bananosCountLabel.text = "INFINITE"
                bananosCountLabel.font = bananosCountLabel.font.withSize(14)
            }
        } else {
            if let bananosCountLabel = self.bananosCountLabel {
                bananosCountLabel.text = "\(quest.winnersAmount)/\(quest.maxWinners)"
                bananosCountLabel.font = bananosCountLabel.font.withSize(17)
            }
        }
        
        var questPrizeText = "No ETH"
        if quest.prize == "0" || quest.prize == nil {
            questPrizeText = "No ETH"
        } else {
            if let questPrize = quest.prize {
                if let weiPrize = BigInt.init(questPrize) {
                    let ethPrize = EthUtils.convertWeiToEth(wei: weiPrize)
                    questPrizeText = "\(String.init(ethPrize)) ETH"
                } else {
                    questPrizeText = "No ETH"
                }
            } else {
                questPrizeText = "No ETH"
            }
        }
        
        if let prizeValueLabel = self.prizeValueLabel {
            prizeValueLabel.text = questPrizeText
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
            if let questDistanceLabel = self.questDistanceLabel {
                questDistanceLabel.text = distanceText
            }
        } else {
            if let questDistanceLabel = self.questDistanceLabel {
                questDistanceLabel.text = "?"
            }
        }
        if let hintTextView = self.hintTextView {
            hintTextView.text = quest.hint
        }
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            let bananoColor = UIColor(hexString: quest.hexColor ?? "31AADE")
            bananoBackgroundView.backgroundColor = bananoColor
        }
    }
    
    func configureEmptyCell() {
        if let questNameLabel = self.questNameLabel {
            questNameLabel.text = "NONE"
        }
        
        if let bananosCountLabel = self.bananosCountLabel {
            bananosCountLabel.text = "0/0"
        }
        
        if let prizeValueLabel = self.prizeValueLabel {
            prizeValueLabel.text = "0.00 USD"
        }
        
        if let questDistanceLabel = self.questDistanceLabel {
            questDistanceLabel.text = "0M"
        }
        
        if let hintTextView = self.hintTextView {
            hintTextView.text = "NONE"
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
    }
}
