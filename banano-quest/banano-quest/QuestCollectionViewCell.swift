//
//  QuestCollectionViewCell.swift
//  banano-quest
//
//  Created by Michael O'Rourke on 6/27/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit

class QuestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var questName: UILabel!
    @IBOutlet weak var bananoBackground: UIView!
    @IBOutlet weak var bananoStamp: UIImageView!
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bananoBackground.layer.cornerRadius = bananoBackground.frame.size.width / 2
        bananoBackground.clipsToBounds = true
    }
}
