//
//  ZoneCallTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/10/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ZoneCallTableViewCell: UITableViewCell {

    @IBOutlet weak var rep: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var drug: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
