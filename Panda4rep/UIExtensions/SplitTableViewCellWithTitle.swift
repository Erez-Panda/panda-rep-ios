//
//  SplitTableViewCellWithTitle.swift
//  Panda4doctor
//
//  Created by Erez on 1/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class SplitTableViewCellWithTitle: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lastNameTextField.delegate = self
        firstNameTextField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == firstNameTextField{
            firstNameLabel.textColor = ColorUtils.buttonColor();
        }
        if textField == lastNameTextField{
            lastNameLabel.textColor = ColorUtils.buttonColor();
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == firstNameTextField{
            firstNameLabel.textColor = ColorUtils.uicolorFromHex(0x9E9E9E)
        }
        if textField == lastNameTextField{
            lastNameLabel.textColor = ColorUtils.uicolorFromHex(0x9E9E9E)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
