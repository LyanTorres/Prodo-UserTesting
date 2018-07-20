//
//  AlphaCollectionViewCell.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 7/10/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class AlphaUITableViewCell: AssetPropertyTableViewCell {
    
    @IBOutlet weak var alphaSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
