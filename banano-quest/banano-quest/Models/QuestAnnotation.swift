//
//  QuestAnnotation.swift
//  banano-quest
//
//  Created by Pabel Nunez Landestoy on 8/3/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//

import Foundation
import MapKit

class QuestAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    let image: UIImage
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D, image: UIImage) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        self.image = image
        super.init()
    }
}
