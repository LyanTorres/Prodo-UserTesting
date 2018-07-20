//
//  Asset.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class Asset: UIView, NSCopying {
    let name: String
    let previewImage: UIImage
    var location: CGRect?
    
    var isSelected: Bool {
        didSet {
            if isSelected == true {
                self.layer.borderColor = UIColor(displayP3Red: 249/255, green: 151/255, blue: 34/255, alpha: 1).cgColor
                self.layer.borderWidth = 4
            }
            else {
                self.layer.borderWidth = 0
            }
        }
    }
    
    
    init(frame: CGRect, name: String, previewImage: UIImage) {
        self.name = name
        self.previewImage = previewImage
        self.isSelected = false
        super.init(frame: frame)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Asset(frame: self.frame, name: self.name, previewImage: self.previewImage)
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: "name") as? String,
            let frame = decoder.decodeObject(forKey: "frame") as? CGRect,
            let previewImage = decoder.decodeObject(forKey: "previewImage") as? UIImage,
            let location = decoder.decodeObject(forKey: "location") as? CGRect else {
                print("error aseets")
                return nil }
        self.init(frame: frame, name: name, previewImage: previewImage)
        self.location = location
    }
    
   override func encode(with aCoder: NSCoder) {
          
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.previewImage, forKey: "previewImage")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.frame, forKey: "frame")
    }
    
}
