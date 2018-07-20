//
//  testLayer.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class Text: Asset {
    
    var textLabel: UILabel {
        didSet{
            let size = textLabel.text?.size(withAttributes: [.font: textLabel.font]) ?? .zero
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size.width, height: size.height)
        }
    }
    
    var text: String {
        set (newText) {
            self.textLabel.text = newText
            self.textLabel.sizeToFit()
            self.textLabel.frame = CGRect(x: 0, y: 0, width: self.textLabel.frame.width + 20, height: self.textLabel.frame.height + 20)
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.textLabel.frame.width, height: self.textLabel.frame.height)
            self.textLabel.textAlignment = .center
        }
        get {
            return self.textLabel.text!
        }
    }
    
    var font: UIFont {
        set (newFont) {
            print(font.pointSize)
            self.textLabel.font = newFont
            self.textLabel.sizeToFit()
            self.textLabel.frame = CGRect(x: 0, y: 0, width: self.textLabel.frame.width + 20, height: self.textLabel.frame.height + 20)
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.textLabel.frame.width, height: self.textLabel.frame.height)
            self.textLabel.textAlignment = .center
            
        }
        get {
            return self.textLabel.font
        }
    }
    
    init(frame: CGRect, name: String, text: String, previewImage: UIImage) {
        self.textLabel = UILabel()
        self.textLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.textLabel.text = text
        self.textLabel.textColor = UIColor.white
        self.textLabel.textAlignment = .center
        self.textLabel.font = self.textLabel.font.withSize(30)
        super.init(frame: frame, name: name, previewImage: previewImage)
        self.addSubview(self.textLabel)
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        return  Text(frame: self.frame, name: self.name, text: self.textLabel.text!, previewImage: self.previewImage)
    }
    
    required convenience init?(coder decoder: NSCoder) {
            let name = decoder.decodeObject(forKey: "name") as! String
            let text = decoder.decodeObject(forKey: "text") as! String
            let frame = decoder.decodeCGRect(forKey: "frame")
            let font = decoder.decodeObject(forKey: "font") as! UIFont
            let previewImage = decoder.decodeObject(forKey: "previewImage") as! UIImage
        self.init(frame: frame, name: name, text: text, previewImage: previewImage)
        self.font = font
    }
    
    override func encode(with aCoder: NSCoder) {
        print(self.frame)
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.frame, forKey: "frame")
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.font, forKey: "font")
        aCoder.encode(self.previewImage, forKey: "previewImage")
    }
}
