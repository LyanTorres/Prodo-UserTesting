//
//  icon.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class Icon: Asset {
    
    init(frame: CGRect, name: String, image: UIImage) {
     
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let parentFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        super.init(frame: parentFrame, name: name, previewImage: image)
        self.addSubview(imageView)
    }
    override func copy(with zone: NSZone? = nil) -> Any {
        //let copy = super.copy(with: zone) as! Icon
        return  Icon(frame: self.frame, name: self.name, image: self.previewImage)
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let name = decoder.decodeObject(forKey: "name") as! String
        let image = decoder.decodeObject(forKey: "image") as! UIImage
        let frame = decoder.decodeCGRect(forKey: "frame")
        self.init(frame: frame, name: name, image: image)
    }
    
    override func encode(with aCoder: NSCoder) {
        print(self.frame)
        aCoder.encode(self.frame, forKey: "frame")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.previewImage, forKey: "image")
    }
}
