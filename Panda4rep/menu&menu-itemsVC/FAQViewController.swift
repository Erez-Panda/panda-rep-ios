//
//  FAQViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/16/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class FAQViewController: PandaViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let questions = ["How do you schedule a video call?","My connection isn't very good. What can I do?", "How to solve technical problems during a call?", "How do you select pharmaceutical experts?", "Is your service satisfaction guaranteed?", "Is my personal information safe?", "How do I update my password and other account information?", "Where is your service available?", "Are your pharmaceutical experts available outside of the U.S.?", "Who can I ask if I have additional questions?"]
    
    let answers = ["Click and get instant live professional video call with a pharmaceutical expert re any given drug. To schedule a call, Click on 'video calls' and choose a product you want to talk about. You can do it by searching it by therapy area or by product. Once you find the product, click on it and then choose a suitable time for you. Once you schedule the call, an email will be sent to you instantly with all the call's details. 30 minutes before the call you'll get a notification through the app/via email. At the time you chose just click on the link that appears in the email or simply enter the app and you'll be directed into a video call with a pharmaceutical expert.", "If you have not enabled WIFI, then we strongly recommend you do so. This can greatly improve the speed of your connection and quality of your experience. You can enable WIFI on most phones by going to SETTINGS and then selecting WIFI.", "You can either open the chat box (by tapping on the screen and clicking on the chat box) and get a help from the pharmaceutical expert or contact LiveMed via email at service@livemed.co", "Each of our providers goes through a rigorous selection process to become a part of the LiveMed network. Subsequently, each pharmaceutical expert is monitored via our rating system to ensure high quality of calls. The initial selection involves an interview with our pharmaceutical experts (including a thorough review of their professional experience and academic background), rigorous training, exams and controlled simulations to ensure high level of calls.", "Yes! Our service couldn't exist without happy customers. If you are unhappy with our service, for whatever reason, do not hesitate to contact our Customer Support team. Email service@livemed.co to get support from a Customer Support agent. Also, If you have any questions about how and when to use LiveMed please email service@livemed.co", "Your privacy and safety is our priority. Your information is stored on our encrypted servers inside encrypted databases. Only strong-encryption API's may access the data via our mobile application. Our systems and servers have been carefully designed to meet HIPAA, NIST and ISO security standards.", "To reset your password, email or update any other account information visit the 'Profile' page in the app and click the edit button. If you are still having issues please email service@livemed.co", "We operate in the U.S and in other English speaking Countries. We intend to shortly offer our services in other languages as well.", "LiveMed is available to you anywhere there is a WIFI or data network. At this stage, we offer our services in English.", "For additional inquiries, you can contact LiveMed via email at service@livemed.co or by writing to us via regular mail at: LiveMed, 550 S California Ave., suite #1, Palo Alto, CA 94306"]
    
    var expendedIndex = -1
    var expendedCell: FAQTableViewCell?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero

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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("faqCell", forIndexPath: indexPath) as! FAQTableViewCell
        cell.questionText.attributedText = ViewUtils.getAttrText(questions[indexPath.row], color: UIColor.blackColor(), size: 16.0)
        cell.answerText.attributedText = ViewUtils.getAttrText(answers[indexPath.row], color: UIColor.blackColor(), size: 16.0)
        cell.expendButton.tag = indexPath.row
        cell.expendButton.addTarget(self, action: "expend:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        toogle(indexPath)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        close(tableView.cellForRowAtIndexPath(indexPath) as! FAQTableViewCell , indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == expendedIndex){
            if let cell = expendedCell {
                cell.answerText.sizeToFit()
                let contentHeight = cell.answerText.frame.height + 76.0
                return contentHeight as CGFloat
            }
        }
        return 66.0

    }
    
    func expend(sender: UIButton){
        let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
        toogle(indexPath)
        
    }
    func close(cell: FAQTableViewCell, indexPath: NSIndexPath){
        cell.questionText.attributedText = ViewUtils.getAttrText(questions[indexPath.row], color: UIColor.blackColor(), size: 16.0, fontName: "OpenSans")
        cell.expendButton.setImage(UIImage(named: "plus_faq"), forState: UIControlState.Normal)
        cell.answerText.hidden = true
        tableView.beginUpdates()
        expendedIndex = -1
        tableView.endUpdates()
    }
    
    func toogle(indexPath: NSIndexPath){
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FAQTableViewCell
        if (cell.answerText.hidden){
            cell.questionText.attributedText = ViewUtils.getAttrText(questions[indexPath.row], color: ColorUtils.buttonColor(), size: 16.0, fontName: "OpenSans-Semibold")
            cell.expendButton.setImage(UIImage(named: "minus_faq"), forState: UIControlState.Normal)
            cell.answerText.hidden = false
            expendedCell = cell
            tableView.beginUpdates()
            expendedIndex = indexPath.row
            tableView.endUpdates()
        } else {
            close(cell, indexPath: indexPath)
        }
    }
    


}
