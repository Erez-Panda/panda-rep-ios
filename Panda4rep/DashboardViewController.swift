//
//  DashboardViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/4/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import YLProgressBar
import PNChart

class DashboardViewController: PandaViewController {

    @IBOutlet weak var callTargetView: UIView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var retentionView: UIView!
    @IBOutlet weak var workingDaysView: UIView!
    @IBOutlet weak var callPerDayView: UIView!
    
    @IBOutlet weak var progressBar: YLProgressBar!
    
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var retentionLabel: UILabel!
    @IBOutlet weak var workingDaysLabel: UILabel!
    @IBOutlet weak var callPerDayLabel: UILabel!
    
    @IBOutlet weak var onDemandPushChartView: UIView!
    @IBOutlet weak var planedCallsChartView: UIView!
    
    var calls = []
    var postCalls = []
    var monthlyTarget = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressBar.type = YLProgressBarType.Flat
        progressBar.progressTintColor = ColorUtils.buttonColor()
        progressBar.hideStripes = true
        progressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayMode.Progress
        progressBar.trackTintColor = UIColor.lightGrayColor()
        progressBar.indicatorTextLabel.textColor = UIColor.whiteColor()
        self.progressBar.progress = 0
        
        ViewUtils.borderView(progressBar, borderWidth: 1, borderColor: UIColor.clearColor(), borderRadius: 3)
        
        let now = NSDate()
        ServerAPI.getUserPostCallsInTimeFrame(now.dateByAddingTimeInterval(-30*24*60*60), end: now) { (result) -> Void in
            self.postCalls = result
            ServerAPI.getUserCallsInTimeFrame(now.dateByAddingTimeInterval(-30*24*60*60), end: now) { (result) -> Void in
                self.calls = result
                dispatch_async(dispatch_get_main_queue()){
                    self.plotCharts()
                }
            }
            dispatch_async(dispatch_get_main_queue()){
                self.ratingLabel.text = String(format: "%.1f", self.averageRating(self.postCalls))
                let wDays = self.workDays(self.postCalls)
                self.workingDaysLabel.text = String(format: "%.00f%%", 32.0)
                self.callPerDayLabel.text = String(format: "%.1f", Double(self.postCalls.count)/Double(wDays))
                self.progressBar.progress = CGFloat(Double(self.postCalls.count) / self.monthlyTarget)
            }
        }
        
        ServerAPI.getUserRetentionRate { (result) -> Void in
            if let rate = result["retention_rate"] as? NSNumber{
                dispatch_async(dispatch_get_main_queue()){
                    let rateDouble = Double(rate)
                    self.retentionLabel.text = String(format: "%.00f%%", rateDouble*100)
                }
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        

        // Do any additional setup after loading the view.
    }
    
    
    func averageRating(postCalls: NSArray) -> Double{
        var totalRating = 0
        var ratingCount = 0
        for i in 0..<postCalls.count {
            if let postCall = postCalls[i] as? NSDictionary{
                if let rating = postCall["doctorRating"] as? Int{
                    if rating > 0 {
                        totalRating += rating
                        ratingCount++
                    }
                }
            }
        }
        return Double(totalRating)/Double(ratingCount)
    }
    
    func workDays(postCalls: NSArray) -> Int{
        let activeDays : NSMutableDictionary = [:]
        for i in 0..<postCalls.count {
            if let postCall = postCalls[i] as? NSDictionary{
                if let dateStr = postCall["start"] as? String{
                    let date = TimeUtils.serverDateTimeStrToDate(dateStr)
                    let comp = TimeUtils.getDateComponentsFromDate(date)
                    if activeDays[comp.day] == nil{
                        activeDays[comp.day] = 0
                    } else {
                        activeDays[comp.day] = (activeDays[comp.day] as! Int) + 1
                    }

                }
            }
        }
        return activeDays.count
    }
    
    func onDemandCalls(postCalls: NSArray, calls: NSArray) -> Int{
        var onDemandCounter = 0
        for i in 0..<postCalls.count {
            if let postCall = postCalls[i] as? NSDictionary{
                if let callId = postCall["call"] as? NSNumber{
                    for j in 0..<calls.count{
                        if let call = calls[j] as? NSDictionary{
                            if let id = call["id"] as? NSNumber{
                                if callId == id {
                                    if let type = call["type"] as? String{
                                        if type == "on-demand" {
                                            onDemandCounter++
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return onDemandCounter
    }
    
    func plotPieChart(view: UIView, items: NSArray, absoluteValue: Bool){
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let width = min(view.frame.height-35, view.frame.width-10)
        let pieChart = PNPieChart(frame: CGRectMake((view.frame.width-width)/2, 30, width, width), items: items as [AnyObject])
        pieChart.descriptionTextColor = UIColor.whiteColor()
        pieChart.descriptionTextFont = UIFont(name: "OpenSans", size: 10.0 )
        pieChart.showAbsoluteValues = absoluteValue
        pieChart.showOnlyValues = false
        pieChart.strokeChart()
        view.addSubview(pieChart)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        ViewUtils.bottomBorderView(callTargetView, borderWidth: 1, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.bottomBorderView(ratingView, borderWidth: 1, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.bottomBorderView(retentionView, borderWidth: 1, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.leftBorderView(retentionView, borderWidth: 1, borderColor: UIColor.lightGrayColor())
        ViewUtils.bottomBorderView(workingDaysView, borderWidth: 1, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.bottomBorderView(callPerDayView, borderWidth: 1, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.leftBorderView(callPerDayView, borderWidth: 1, borderColor: UIColor.lightGrayColor())
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func plotCharts(){
        for view in planedCallsChartView.subviews {
            view.removeFromSuperview()
        }
        for view in onDemandPushChartView.subviews {
            view.removeFromSuperview()
        }
        self.plotPieChart(self.planedCallsChartView,
            items: [PNPieChartDataItem(value: CGFloat(self.postCalls.count), color:  ColorUtils.buttonColor(), description:"Delivered"),
                PNPieChartDataItem(value: CGFloat(max(self.calls.count-self.postCalls.count, 0)), color: UIColor.lightGrayColor())],
            absoluteValue: false)
        let onDemandCount = self.onDemandCalls(self.postCalls, calls: self.calls)
        self.plotPieChart(self.onDemandPushChartView,
            items: [PNPieChartDataItem(value: CGFloat(onDemandCount), color: ColorUtils.buttonColor() , description:"On Demand"),
                PNPieChartDataItem(value: CGFloat(self.postCalls.count-onDemandCount), color: UIColor.lightGrayColor(), description:"Push")],
            absoluteValue: false)
    }
    
    func rotated(){
        plotCharts()
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
