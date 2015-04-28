//
//  SearchTypeTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/3/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class SearchTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    //var type: SearchViewController.SearchType?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
