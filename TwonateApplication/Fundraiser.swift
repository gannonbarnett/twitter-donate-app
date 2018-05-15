//
//  Fundraiser.swift
//  TwonateApplication
//
//  Created by Max Goldberg on 5/13/18.
//  Copyright © 2018 BarnettDevelopmentCompany. All rights reserved.
//

import UIKit

class Fundraiser: NSObject {
    var name: String
    var progress: Double
    var handle: String
    var keyword: String = ""
    var image: UIImage?
    
    init(name: String, progress: Double, handle: String, image: UIImage?) {
        self.name = name
        self.progress = progress
        self.handle = handle
        self.image = image
    }
}
