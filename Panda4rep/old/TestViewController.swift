//
//  TestViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/28/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var resourceId: NSNumber!
    var testId: NSNumber?
    var questions: NSArray?
    var currQuestionIndex: Int = 0
    var answers: NSArray?
    var selectedAnswer: NSDictionary?
    var score: NSNumber = 0
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answersTable: UITableView!
    @IBOutlet weak var answerButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadQuestionData(index: Int){
        if let currQuestion = self.questions?[index] as? NSDictionary{
            self.questionLabel.text = currQuestion["question"] as! NSString as String
            ServerAPI.getQuestionAnswers(currQuestion["id"] as! NSNumber, completion: { (result) -> Void in
                self.answers = result
                dispatch_async(dispatch_get_main_queue()){
                    self.answersTable.reloadData()
                }
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.answers = []
        ServerAPI.getResourceTest(resourceId) { (result) -> Void in
            self.testId = result["id"] as? NSNumber
            ServerAPI.getTestQuestions(self.testId!, completion: { (result) -> Void in
                self.questions = result
                self.loadQuestionData(self.currQuestionIndex)
            })
            
        }
    }
    
    @IBAction func answer(sender: AnyObject) {
        if self.selectedAnswer?["correct"] as! Bool{
            self.score = self.score.integerValue + 1
        }
        self.currQuestionIndex++
        if self.currQuestionIndex == (self.questions!.count-1) {
            self.answerButton.titleLabel?.text = "Send"
        }
        if self.currQuestionIndex > (self.questions!.count-1) {
            let s: Double = self.score.doubleValue/Double(self.questions!.count)
            let testResult = ["test": self.testId as NSNumber!,
                              "score": self.score,
                              "completed": (s > 0.8) ? true: false] as Dictionary<String, AnyObject>
            ServerAPI.answerTest(testResult, completion: { (result) -> Void in
                //
            })
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        loadQuestionData(self.currQuestionIndex)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answers!.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answerCell")!
        let answer = self.answers?[indexPath.row] as! NSDictionary
        let answerTest = answer["answer"] as! String
        cell.textLabel?.text = answerTest
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedAnswer = self.answers?[indexPath.row] as? NSDictionary
    }
    
}