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
    // Variables
    var quest: Quest?
    
    // IBOutlet
    @IBOutlet weak var questNameLabel: UILabel?
    @IBOutlet weak var bananosCountLabel: UILabel?
    @IBOutlet weak var prizeValueLabel: UILabel?
    @IBOutlet weak var questDistanceLabel: UILabel?
    @IBOutlet weak var bananoBackgroundView: UIImageView?
    @IBOutlet weak var bananoStampImage: UIImageView?
    @IBOutlet weak var hintTextView: UITextView?
    @IBOutlet weak var summaryBackgroundImageView: UIImageView!
    @IBOutlet weak var bottomSeparator: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            bananoBackgroundView.layer.cornerRadius = bananoBackgroundView.frame.size.width / 2
            bananoBackgroundView.clipsToBounds = true
        }
    }
    
    func configureCellFor(index: Int, playerLocation: CLLocation?) {
        // TODO:
        // DISTANCE FROM QUEST
        guard let quest = self.quest else {
            self.configureEmptyCellFor(index: index)
            return
        }
        
        if let questNameLabel = self.questNameLabel {
            questNameLabel.text = quest.name.uppercased()
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
            
            DispatchQueue.main.async {
                // Adjust textView height and background image depending on text content
                let fixedWidth = self.frame.size.width
                // TODO: Find a better way to do this

                if let newSize = self.hintTextView?.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)) {
                    
                    let device = UIDevice.modelName
                    if device == "iPhone SE" || device == "Simulator iPhone SE"{
                        // Change hint text view frame
                        self.hintTextView?.frame = CGRect(x: self.hintTextView?.frame.origin.x ?? 0, y: self.hintTextView?.frame.origin.y ?? 0, width: fixedWidth, height: 45)
                        
                        // Change summary background image frame
                        var originX = self.hintTextView?.frame.origin.x ?? 20
                        originX = originX - 20
                        
                        self.summaryBackgroundImageView?.frame = CGRect(x: originX, y: self.hintTextView?.frame.origin.y ?? 0, width: fixedWidth + 20, height: self.hintTextView!.frame.height + 54)
                        
                        // Change bottom separator frame
                        self.bottomSeparator.frame = CGRect(x: 20, y: self.summaryBackgroundImageView.frame.height + 41, width: self.hintTextView?.frame.width ?? 100 - 20, height: 2)
                        
                        // Change hint label frame
                        self.hintLabel.frame = CGRect(x: 20, y: self.summaryBackgroundImageView.frame.height + 45, width: self.hintTextView?.frame.width ?? 100 - 10, height: 20)
                    }else{
                        // Change hint text view frame
                        self.hintTextView?.frame = CGRect(x: self.hintTextView?.frame.origin.x ?? 0, y: self.hintTextView?.frame.origin.y ?? 0, width: fixedWidth, height: newSize.height)
                        
                        // Change summary background image frame
                        var originX = self.hintTextView?.frame.origin.x ?? 20
                        originX = originX - 20
                        
                        self.summaryBackgroundImageView?.frame = CGRect(x: originX, y: self.hintTextView?.frame.origin.y ?? 0, width: fixedWidth + 20, height: self.hintTextView!.frame.height + 40)
                        
                        // Change bottom separator frame
                        self.bottomSeparator.frame = CGRect(x: 20, y: self.summaryBackgroundImageView.frame.height + 39, width: self.hintTextView?.frame.width ?? 100 - 20, height: 2)
                        
                        // Change hint label frame
                        self.hintLabel.frame = CGRect(x: 20, y: self.summaryBackgroundImageView.frame.height + 43, width: self.hintTextView?.frame.width ?? 100 - 10, height: 20)
                    }

                }
                
            }
        }
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            let bananoColor = UIColor(hexString: quest.hexColor ?? "31AADE")
            bananoBackgroundView.backgroundColor = bananoColor
        }
    }
    
    func configureEmptyCellFor(index: Int) {
        if let bananoQuestImage = self.bananoStampImage {
                bananoQuestImage.image = #imageLiteral(resourceName: "NO-BANANO")
        }
        
        if index > 0 {
            if let questNameLabel = self.questNameLabel {
                questNameLabel.text = ""
            }
            
            return
        }
        
        if let questNameLabel = self.questNameLabel {
            questNameLabel.text = "NO BANANOS YET"
        }
        
        if let bananosCountLabel = self.bananosCountLabel {
            bananosCountLabel.text = "N/A"
        }
        
        if let prizeValueLabel = self.prizeValueLabel {
            prizeValueLabel.text = "N/A"
        }
        
        if let questDistanceLabel = self.questDistanceLabel {
            questDistanceLabel.text = "N/A"
        }
        
        if let hintTextView = self.hintTextView {
            hintTextView.text = "N/A"
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
    }
}
