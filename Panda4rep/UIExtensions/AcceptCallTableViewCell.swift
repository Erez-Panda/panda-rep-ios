//
//  ZoneCallTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/10/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class AcceptCallTableViewCell: ZoneCallTableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
