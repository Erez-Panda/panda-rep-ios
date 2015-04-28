//
//  TableViewCellWithTextView.swift
//  Panda4doctor
//
//  Created by Erez on 1/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class TableViewCellWithTextView: UITableViewCell {
    
    
    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
