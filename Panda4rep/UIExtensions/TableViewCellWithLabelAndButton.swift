//
//  TableViewCellWithLabelAndButton.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/1/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class TableViewCellWithLabelAndButton: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
