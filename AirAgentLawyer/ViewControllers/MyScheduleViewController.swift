//
//  MyScheduleViewController.swift
//  AirAgentLawyer
//
//  Created by cears infotech on 11/26/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit
class ScheduleCell : UITableViewCell
{
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblDate : UILabel!
}
class MyScheduleViewController: UIViewController,RSDFDatePickerViewDelegate , RSDFDatePickerViewDataSource, UITableViewDataSource,UITableViewDelegate  {

    @IBOutlet var calenderView : RSDFDatePickerView!
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var tblSchedule : UITableView!
    
    var datesToMark : NSMutableArray = NSMutableArray()
    var arrName : NSMutableArray = NSMutableArray()
    var arrStatus : NSMutableArray = NSMutableArray()
    
    let calendar = NSCalendar.currentCalendar()
    var today : NSDate!
    var agentID : String = ""
    var Token : String = ""
    var arrOfSchedule : NSMutableArray = NSMutableArray()
    var dateToSend : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calenderView.delegate = self
        calenderView.dataSource = self
        calenderView.pagingEnabled = true
        
//        self.datesToMark.addObject("2016-08-05")
//        self.datesToMark.addObject("2016-08-08")
//        self.datesToMark.addObject("2016-08-13")
//        self.datesToMark.addObject("2016-08-17")

        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
            }
        }
        self.tblSchedule.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.todayDate()
        self.calenderView.selectDateMember(self.today)
    //    self.getScheduleData()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.getScheduleData()
    }
    //MARK: RSDFLowLayout Delegate Datasource
    
    func todayDate() -> NSDate
    {
        let todayComponents: NSDateComponents = self.calendar.components(([.Year, .Month, .Day]), fromDate: NSDate())
        self.today = self.calendar.dateFromComponents(todayComponents)
        print("date format today",self.today)

        return self.today
    }
    
    func datePickerView(view: RSDFDatePickerView, shouldHighlightDate date: NSDate) -> Bool
    {
        return true
    }
    
    func datePickerView(view: RSDFDatePickerView, shouldSelectDate date: NSDate) -> Bool {
        
        return true
    }
    
    func datePickerView(view: RSDFDatePickerView, didSelectDate date: NSDate)
    {
        print("selected date" , date)
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let dateVal :String  = dateFormat.stringFromDate(date)
        
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dt = formatter.stringFromDate(date)
        dateToSend = dt
        
        if (self.datesToMark.containsObject(dateVal))
        {
            var mentionObj : DataSchedule = DataSchedule()
            for i in 0 ..< self.datesToMark.count
            {
                if(self.datesToMark[i] as! String == dateVal )
                {
                    print("index pos")
                mentionObj = self.arrOfSchedule.objectAtIndex(i) as! DataSchedule
                    let editPost = self.storyboard?.instantiateViewControllerWithIdentifier("AddScheduleViewController") as! AddScheduleViewController
                    editPost.fromEdit = "yes"
                    editPost.objectVal = mentionObj
                    self.navigationController?.pushViewController(editPost, animated: true)
                    return
                    
                }
            }
            
        }
        else
        {
            print("need to go at new schedul")
            let addSchedule = self.storyboard?.instantiateViewControllerWithIdentifier("AddScheduleViewController") as! AddScheduleViewController
            addSchedule.selectedDate = dateToSend
            
            self.navigationController?.pushViewController(addSchedule, animated: true)
        }
        
   
    }
    
    func datePickerView(view: RSDFDatePickerView, markImageColorForDate date: NSDate) -> UIColor {
        
        
        return UIColor(red: 102/255, green: 172/255, blue: 237/255, alpha: 1.0)
    }

    func getScheduleData()
    {
        //API Calling
        var arrMention : NSArray = NSArray()
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let str = "Agent/GetShedule?AgentId="+self.agentID
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+str)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.Token, forHTTPHeaderField: "Token")
        request.addValue(self.agentID, forHTTPHeaderField: "UserId")
        
        GlobalClass.sharedInstance.get(request, params: "") { (success, object) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("obj",object)
                if success
                {
                    GlobalClass.sharedInstance.stopIndicator()
                    
                    if let object = object
                    {
                        print("response object of schedule data",object)
                        self.arrOfSchedule = []
                        self.datesToMark = []
                        if(!object.valueForKey("Data")!.isKindOfClass(NSNull))
                        {
                            print("not null")
                            arrMention = object.valueForKey("Data") as! NSArray
                            for i in 0  ..< arrMention.count
                            {
                                let mentionObj : DataSchedule = DataSchedule()
                                
                                mentionObj.DetailId = (arrMention[i].valueForKey("DetailId") as? Int)!
                                mentionObj.CourtName = arrMention[i].valueForKey("CourtName") as? String ?? ""
                                mentionObj.LocationId = (arrMention[i].valueForKey("LocationId") as? Int)!
                                if(!arrMention[i].valueForKey("FirstHourRate")!.isKindOfClass(NSNull))
                                {
                                    mentionObj.FirstHourRate = (arrMention[i].valueForKey("FirstHourRate") as? Int)!
                                }
                                else
                                {
                                    
                                }
                                if(!arrMention[i].valueForKey("AfterFirstHourRate")!.isKindOfClass(NSNull))
                                {
                                    mentionObj.AfterFirstHourRate = (arrMention[i].valueForKey("AfterFirstHourRate") as? Int)!
                                }
                                mentionObj.Rate = (arrMention[i].valueForKey("Rate") as? Int)!
                                mentionObj.SheduleDate = arrMention[i].valueForKey("SheduleDate") as? String ?? ""
                                mentionObj.IsActive = (arrMention[i].valueForKey("IsActive") as? Bool)!
                                var dateToAdd : String = ""
                                let formatter : NSDateFormatter = NSDateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                let dt = formatter.dateFromString(mentionObj.SheduleDate)
                                formatter.dateFormat = "dd/MM/yyyy"
                                dateToAdd = formatter.stringFromDate(dt!)
                                self.datesToMark.addObject(dateToAdd)
                               
                                self.arrOfSchedule.addObject(mentionObj)
                            }
                            self.calenderView.reloadData()
                            self.tblSchedule.delegate = self
                            self.tblSchedule.dataSource = self
                           self.tblSchedule.reloadData()
                        }
                        else
                        {
                            print("no data availabel")
                            self.tblSchedule.delegate = self
                            self.tblSchedule.dataSource = self
                            self.tblSchedule.reloadData()
                        }

                    }
                    
                }
                else
                {
                    print("failure part")
                    GlobalClass.sharedInstance.stopIndicator()
                }
            })
        }
    }
    
    @IBAction func btnBack(sender : UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func datePickerView(view: RSDFDatePickerView, shouldMarkDate date: NSDate) -> Bool
    {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let dateVal :String  = dateFormat.stringFromDate(date)
        print(dateVal)
        print("date to makr" , self.datesToMark)
        print("tru/false", self.datesToMark.containsObject(dateVal))
        return self.datesToMark.containsObject(dateVal)
    }
    //MARK : tableview delegate and datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(self.arrOfSchedule.count > 0)
        {
            return self.arrOfSchedule.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.arrOfSchedule.count > 0)
        {
            return 55
        }
        else
        {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(self.arrOfSchedule.count > 0)
        {
            let cell:ScheduleCell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell") as! ScheduleCell
            let mentionObj = self.arrOfSchedule.objectAtIndex(indexPath.row) as! DataSchedule
            
            cell.lblTitle?.text = mentionObj.CourtName
           
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dt = formatter.dateFromString(mentionObj.SheduleDate)
            formatter.dateFormat = "dd/MM/yyyy"
            print(formatter.stringFromDate(dt!))
            cell.lblDate?.text = formatter.stringFromDate(dt!)
           
            return cell
        }
        else
        {
            
            self.tblSchedule.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.text = NSLocalizedString("Schedule Not Available.", comment: "comm")
            cell.textLabel?.textColor = UIColor(red: 57/255, green: 80/255, blue: 99/255, alpha: 1.0)
            cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            return cell
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
