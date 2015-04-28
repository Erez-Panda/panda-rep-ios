//
//  ArticleTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/4/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    var bookmarked = false
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
