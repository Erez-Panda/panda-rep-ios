//
//  PromoTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/16/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class PromoTableViewCell: UITableViewCell {

    var bookmarked = false
    
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var promoImageView: UIImageView!
    @IBOutlet weak var bookmarkButton: ButtonWithData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
