//
//  FAQTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/16/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class FAQTableViewCell: UITableViewCell {

    @IBOutlet weak var questionText: UITextView!
    @IBOutlet weak var answerText: UITextView!
    @IBOutlet weak var expendButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        questionText.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
        answerText.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
