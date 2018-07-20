//
//  isAnimatedTableViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 7/1/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class AnimatedTableViewCell: UITableViewCell {

    @IBOutlet weak var isAnimatedSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
