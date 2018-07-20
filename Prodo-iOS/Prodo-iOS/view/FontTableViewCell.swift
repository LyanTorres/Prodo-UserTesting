//
//  FontTableViewCell.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 7/12/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class FontTableViewCell: AssetPropertyTableViewCell {
    
    @IBOutlet weak var fontlabel:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

