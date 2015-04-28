//
//  TableViewCellWithButtonAndTitle.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class TableViewCellWithButtonAndTitle: UITableViewCell {
    @IBOutlet weak var dropDown: UIButton!
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
    func textFieldDidBeginEditing(textField: UITextField) {
        label.textColor = ColorUtils.buttonColor();
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        label.textColor = ColorUtils.uicolorFromHex(0x9E9E9E)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
