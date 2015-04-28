//
//  TableViewCellWithTitle.swift
//  Panda4doctor
//
//  Created by Erez on 1/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class TableViewCellWithTitle: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textInput.delegate = self
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
