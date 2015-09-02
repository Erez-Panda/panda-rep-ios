//
//  MedicalInquiryTableViewCell.swift
//  Panda4doctor
//
//  Created by Erez Haim on 3/3/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class MedicalInquiryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var drug: UILabel!
    @IBOutlet weak var doctor: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
