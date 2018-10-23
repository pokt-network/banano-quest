//
//  BananoCollectionViewCell.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 10/23/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import SwiftHEXColors
import MapKit
import BigInt

class BananoCollectionViewCell: UICollectionViewCell {
    // Variables
    var banano: Banano?
    
    // IBOutlet
    @IBOutlet weak var questNameLabel: UILabel?
    @IBOutlet weak var bananoBackgroundView: UIImageView?
    @IBOutlet weak var bananoStampImage: UIImageView?

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            bananoBackgroundView.layer.cornerRadius = bananoBackgroundView.frame.size.width / 2
            bananoBackgroundView.clipsToBounds = true
        }
    }
    
    func configureCellFor(index: Int, playerLocation: CLLocation?) {
        
        guard let banano = self.banano else {
            self.configureEmptyCellFor(index: index)
            return
        }
        
        if let questNameLabel = self.questNameLabel {
            questNameLabel.text = banano.questName?.uppercased()
        }
        
        if let bananoBackgroundView = self.bananoBackgroundView {
            let bananoColor = UIColor(hexString: banano.hexColor ?? "31AADE")
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
        
    }
    
}
