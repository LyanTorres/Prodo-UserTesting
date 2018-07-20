//
//  Card.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class Card: NSObject, NSCoding  {
    var assets: [Asset]
    var backgroundImage: UIImage
    var thumnail: UIImage
    
    init(assets: [Asset], background: UIImage) {
        self.assets = assets
        self.backgroundImage = background
        self.thumnail = background;
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let assets = decoder.decodeObject(forKey: "assets") as? [Asset],
            let backgroundImage = decoder.decodeObject(forKey: "backgroundImage") as? UIImage,
            let thumnail = decoder.decodeObject(forKey: "thumnail") as? UIImage else {return nil}
        self.init(assets: assets, background: backgroundImage)
        self.thumnail = thumnail
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.assets, forKey: "assets")
        aCoder.encode(self.backgroundImage, forKey: "backgroundImage")
        aCoder.encode(self.thumnail, forKey: "thumnail")
    }
}
