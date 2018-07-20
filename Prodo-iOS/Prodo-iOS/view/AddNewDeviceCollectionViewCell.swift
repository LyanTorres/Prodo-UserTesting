//
//  AddNewDeviceCollectionViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class AddNewDeviceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var addNewDeviceBackgroundView: UIView!
    
    override func awakeFromNib() {
        addNewDeviceBackgroundView.layer.cornerRadius = 5
    }

}
