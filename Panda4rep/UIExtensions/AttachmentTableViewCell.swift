//
//  AttachmentTableViewCell.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/30/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class AttachmentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkboxButton.setImage(UIImage(named: "glyphicons-153-check")?.imageWithColor(UIColor.grayColor()), forState: UIControlState.Selected)
        checkboxButton.setImage(UIImage(named: "glyphicons-154-unchecked")?.imageWithColor(UIColor.grayColor()), forState: UIControlState.Normal)
        checkboxButton.selected = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
