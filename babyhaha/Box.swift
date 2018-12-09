//
//  Box.swift
//  babyhaha
//
//  Created by Sai~ on 12/1/18.
//  Copyright © 2018 nyu. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Box{
    
    var title: String
    var category: String
    var tag: String
    var coverImage: UIImage
    var items: [UIImage] = []
    var description:String
    var location: String
    var owner: String
    
    init(title: String, category: String, tag: String, coverImage: UIImage, description: String, location: String, owner: String) {
        self.title = title
        self.category = category
        self.tag = tag
        self.coverImage = coverImage
        self.description = description
        self.location = location
        self.owner = owner
    }
}
