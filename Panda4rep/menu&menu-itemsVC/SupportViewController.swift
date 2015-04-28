//
//  SupportViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/16/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class SupportViewController: PandaViewController {

    @IBOutlet weak var faqButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.borderView(contactButton, borderWidth: 1.0, borderColor: ColorUtils.buttonColor(), borderRadius: 3)
        ViewUtils.borderView(faqButton, borderWidth: 1.0, borderColor: ColorUtils.buttonColor(), borderRadius: 3)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
