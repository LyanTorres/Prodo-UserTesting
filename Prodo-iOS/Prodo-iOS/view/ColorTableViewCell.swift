//
//  ColorTableViewCell.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 7/16/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class ColorTableViewCell: UITableViewCell {

    @IBOutlet weak var corlorView: UIView!
    @IBOutlet weak var colorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        corlorView.layer.cornerRadius = 5
        corlorView.layer.borderColor = UIColor.white.cgColor
        corlorView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
