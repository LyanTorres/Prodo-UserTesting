//
//  SizeTableViewCell.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 7/10/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit

class SizeTableViewCell: AssetPropertyTableViewCell {

    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stepper:UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func stepperAdd(sender: UIStepper) {
        sizeLabel.text = stepper.value.description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
