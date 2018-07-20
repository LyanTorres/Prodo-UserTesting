//
//  AssetCollectionViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var assetPreviewImageView: UIImageView!
    @IBOutlet fileprivate weak var assetBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assetBackgroundView.layer.cornerRadius = 6
        assetBackgroundView.layer.masksToBounds = true
        
    }
    
    var image: UIImage? {
        didSet {
            assetPreviewImageView.image = image
        }
    }
    
}
