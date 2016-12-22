//
//  AddScheduleViewController.swift
//  AirAgentLawyer
//
//  Created by cears infotech on 11/26/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class AddScheduleViewController: UIViewController,SBPickerSelectorDelegate {

    let picker : SBPickerSelector = SBPickerSelector.picker()
    var arrOfCategory : NSArray = NSArray()
    var arrOfCourtName : NSMutableArray = NSMutableArray()
    var Token : String = ""
    var agentID : String = ""
    var selectedDate : String = ""
    var courtID : String = ""
    @IBOutlet var btnCourt : UIButton!
    @IBOutlet var txtRate : UITextField!
    @IBOutlet var firstHrRate : UITextField!
    @IBOutlet var nextHrRate : UITextField!
    @IBOutlet var txtAdd1 : UITextField!
    @IBOutlet var txtAdd2 : UITextField!
    @IBOutlet var txtCity : UITextField!
    @IBOutlet var txtState : UITextField!
    @IBOutlet var txtCountry : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.Text
        picker.doneButtonTitle = NSLocalizedString("Done", comment: "comment")
        picker.cancelButtonTitle = NSLocalizedString("Cancel", comment: "commen")
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
            }
        }
        
        self.getCourt()
    }

    func getCourt()
    {
        self.arrOfCategory = []
        self.arrOfCourtName = []
        
        //API Calling
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"/Principle/GetCourt")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.Token, forHTTPHeaderField: "Token")
        request.addValue(self.agentID, forHTTPHeaderField: "UserId")
        
        GlobalClass.sharedInstance.get(request, params: "") { (success, object) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("obj",object)
                GlobalClass.sharedInstance.stopIndicator()
                if success
                {
                    GlobalClass.sharedInstance.stopIndicator()
                    
                    if let object = object
                    {
                        print("response object",object)
                        self.arrOfCategory = object.valueForKey("Data") as! NSArray
                        for i in 0  ..< self.arrOfCategory.count
                        {
                        self.arrOfCourtName.addObject(self.arrOfCategory[i].valueForKey("CourtName")!)
                        }

                    }
                }
            })
        }
    }

    @IBAction func btnCourtClick(sender : UIButton)
    {
            print("click")
            self.view.endEditing(true)
            let point: CGPoint = view.convertPoint(sender.frame.origin, fromView: sender.superview)
            var frame: CGRect = sender.frame
            frame.origin = point
            if(self.arrOfCourtName.count > 0)
            {
                picker.pickerData =  self.arrOfCourtName as [AnyObject]
                picker.showPickerIpadFromRect(frame, inView: view)
            }
    }
    
    //Mark - SBPicker Delegate
    
    func pickerSelector(selector: SBPickerSelector!, selectedValue value: String!, index idx: Int)
    {
        self.btnCourt.setTitle(value, forState: UIControlState.Normal)
        
        self.txtAdd1.text = self.arrOfCategory.objectAtIndex(idx).valueForKey("Address1") as? String
        self.txtAdd2.text = self.arrOfCategory.objectAtIndex(idx).valueForKey("Address2") as? String
        self.txtCity.text = self.arrOfCategory.objectAtIndex(idx).valueForKey("City") as? String
        self.txtState.text = self.arrOfCategory.objectAtIndex(idx).valueForKey("State") as? String
        self.txtCountry.text = self.arrOfCategory.objectAtIndex(idx).valueForKey("Country") as? String
        self.courtID = String(self.arrOfCategory.objectAtIndex(idx).valueForKey("CourtId") as! Int)
        print("court id",self.courtID)
        
    }
    
    @IBAction func btnAddClick(sender : UIButton)
    {
        if(self.btnCourt.titleLabel?.text == NSLocalizedString("Select Court", comment: "comm"))
        {
           GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please Select Court", comment: "comm"))
            return
        }
        if NSString(format:"%@", txtRate.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Rate", comment: "comm"))
            return
        }
        if NSString(format:"%@", firstHrRate.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter First Hour Rate", comment: "comm"))
            return
        }
        if NSString(format:"%@", nextHrRate.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Next Hour Rate", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        print("value is ",self.courtID)
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(self.agentID, forKey: "UserId")
        paramDic.setValue(selectedDate, forKey: "SheduleDate")
        paramDic.setValue(self.courtID, forKey: "LocationId")
        paramDic.setValue(self.txtRate.text, forKey: "Rate")
        paramDic.setValue(self.firstHrRate.text, forKey: "FirstHourRate")
        paramDic.setValue(self.nextHrRate.text, forKey: "AfterFirstHourRate")
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        
        //API Calling
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"/Agent/AddShedule")!)
        print("request",request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.Token, forHTTPHeaderField: "Token")
        request.addValue(self.agentID, forHTTPHeaderField: "UserId")
        
        GlobalClass.sharedInstance.post(request, params: jsonString) { (success, object) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("obj",object)
                GlobalClass.sharedInstance.stopIndicator()
                if success
                {
                    GlobalClass.sharedInstance.stopIndicator()
                    
                    if let object = object
                    {
                        print("response object",object)
                        if(object.valueForKey("IsSuccess") as! Bool == true)
                        {
                            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Schedule Added Successfully", comment: "comm"))
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func btnBack(sender : UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
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
