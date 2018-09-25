//
//  WalletScoreTableViewCell.swift
//  banano-quest
//
//  Created by MetaTedi on 9/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit

class WalletScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var bananosNumberLabel: UILabel!
    @IBOutlet weak var ethereumAddressLabel: UILabel!
    
    var walletString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
