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
    @IBOutlet weak var bananoBackgroundView: UIView!
    @IBOutlet weak var bananoStampImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bananoBackgroundView.layer.cornerRadius = bananoBackgroundView.frame.size.width / 2
        bananoBackgroundView.clipsToBounds = true
    }
    
    func configureCell(quest: Quest) {
        questNameLabel.text = quest.name
        
    }
    
    func configureEmptyCell() {
        
    }
}
