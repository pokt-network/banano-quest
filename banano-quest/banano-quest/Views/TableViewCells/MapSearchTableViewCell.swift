//
//  MapSearchTableViewCell.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 11/19/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import UIKit
import MapKit

class MapSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var place : MKMapItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        titleLabel.text = place?.name
        subtitleLabel.text = place?.placemark.title
    }
    
    func configureEmptyCell() {
        titleLabel.text = ""
        subtitleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
