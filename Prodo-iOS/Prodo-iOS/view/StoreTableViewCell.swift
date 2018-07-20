//
//  StoreTableViewCell.swift
//  Prodo-iOS
//
//  Created by Lyan Torres on 6/18/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeIdentifierLabel: UILabel!
    @IBOutlet weak var deviceCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
