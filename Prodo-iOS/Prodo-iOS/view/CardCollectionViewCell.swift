//
//  CardCollectionViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardPreviewImageView: UIImageView!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                view.layer.borderColor = UIColor(red: 249/255, green: 151/255, blue: 34/255, alpha: 1.0).cgColor
                view.layer.borderWidth = 2
            }
            else {
                 view.layer.borderWidth = 0
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            cardPreviewImageView.image = image
        }
    }
    
    
}
