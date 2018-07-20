//
//  DeviceCollectionViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var liveView: UIView!
    
    var image: String? {
        didSet {
            
            do {
                
                guard let preview = image, let url = URL(string: preview) else {return}
                
                let data = try Data(contentsOf: url)
                self.previewImageView.image = UIImage(data: data)
                self.previewImageView.layer.cornerRadius = 5
                
            }
            catch {
                print(error)
            }
        }
    }
    
    override func awakeFromNib() {
        previewImageView.layer.cornerRadius = 5
        previewImageView.backgroundColor = UIColor.darkGray
        previewImageView.layer.masksToBounds = true
    }

   
}
