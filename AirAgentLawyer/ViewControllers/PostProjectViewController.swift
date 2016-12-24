//
//  PostProjectViewController.swift
//  AirAgentLawyer
//
//  Created by Admin on 22/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class PostProjectViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate,SBPickerSelectorDelegate,UITextViewDelegate{
    

    @IBOutlet var titleCollection : UICollectionView!
    @IBOutlet var heightOfCollectionView : NSLayoutConstraint!
    @IBOutlet var btnCourt : UIButton!
    @IBOutlet var btnDate : UIButton!
    @IBOutlet var txtClientName : UITextField!
    @IBOutlet var txtNoteView : UITextView!
    
    var arrOfCategory : NSArray = NSArray()
    var arrOfCourt : NSArray = NSArray()
    var arrOfCourtName : NSMutableArray = NSMutableArray()
    var arrOfCategoryName : NSMutableArray = NSMutableArray()
    var arrOfLawArea : NSMutableArray = NSMutableArray()
    
    var Token : String = ""
    var agentID : String = ""
    let picker : SBPickerSelector = SBPickerSelector.picker()
    var lawArea : String = ""
    var courtID : String = ""
    var selectedDate : String = ""
    var postype : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
            }
        }
        self.heightOfCollectionView.constant = 0
        picker.delegate = self
        picker.pickerType = SBPickerSelectorType.Text
        picker.doneButtonTitle = NSLocalizedString("Done", comment: "comment")
        picker.cancelButtonTitle = NSLocalizedString("Cancel", comment: "commen")
        self.txtNoteView.text = NSLocalizedString("Notes", comment: "comm")
        self.txtNoteView.textColor = UIColor.darkGrayColor()
        self.txtNoteView.delegate = self
        self.getCourt()
        self.getCategory()
    }

    func getCourt()
    {
        self.arrOfCourt = []
        self.arrOfCourtName = []
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
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
                        self.arrOfCourt = object.valueForKey("Data") as! NSArray
                        for i in 0  ..< self.arrOfCourt.count
                        {
                            self.arrOfCourtName.addObject(self.arrOfCourt[i].valueForKey("CourtName")!)
                        }
                        
                    }
                }
            })
        }
    }
    
    func getCategory()
    {
        self.arrOfCategory = []
        self.arrOfCategoryName = []
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        //API Calling
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"/Register/Getcategory")!)
        
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
                            self.arrOfCategoryName.addObject(self.arrOfCategory[i].valueForKey("CategoryName")!)
                                self.arrOfLawArea.addObject("0")
                        }
                        if((self.arrOfCategoryName.count/2)%2 == 0)
                        {
                            print("even")
                            self.heightOfCollectionView.constant = CGFloat(self.arrOfCategoryName.count/2)*44
                        }
                        else{
                            print("odd")
                            self.heightOfCollectionView.constant = CGFloat((self.arrOfCategoryName.count/2)*44) + 44
                        }
                        
                        print("self.heightOfCollectionView",self.heightOfCollectionView)
                        self.titleCollection.reloadData()
                    }
                }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : TitleCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("TitleCollectionViewCell", forIndexPath: indexPath) as! TitleCollectionViewCell
        cell.btnSelect.addTarget(self, action: #selector(SignupViewController.selectCat(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.btnSelect.tag = indexPath.row
        print("status value",self.arrOfLawArea[indexPath.row])
        if(self.arrOfLawArea[indexPath.row] as! String == "0")
        {
            cell.btnSelect.selected = false
        }
        else
        {
          
            cell.btnSelect.selected = true
        }
        cell.titleName.text = self.arrOfCategoryName[indexPath.row] as? String
        
        return cell
    }
    
    func selectCat(sender : UIButton)
    {
        print("entire array with status and name",self.arrOfLawArea)
        if(sender.selected)
        {
            
        }
        else
        {
            sender.selected = true
            for i in 0 ..< self.arrOfLawArea.count
            {
                if(i == sender.tag)
                {
                   self.arrOfLawArea[i] = "1"
                }
                else
                {
                    self.arrOfLawArea[i] = "0"
                }
            }
            self.postype = String(self.arrOfCategory[sender.tag].valueForKey("CategoryId")! as! Int)
            self.titleCollection.reloadData()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.arrOfCategoryName.count
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
    
    @IBAction func btnDateClick(sender : UIButton)
    {
        picker.pickerType = SBPickerSelectorType.Date
        picker.datePickerType = SBPickerSelectorDateType.OnlyDay
        picker.setMinimumDateAllowed(NSDate())
        
        self.view.endEditing(true)
        let point: CGPoint = view.convertPoint(sender.frame.origin, fromView: sender.superview)
        var frame: CGRect = sender.frame
        frame.origin = point
        picker.showPickerIpadFromRect(frame, inView: view)
    }

    
    //Mark - SBPicker Delegate
    
    func pickerSelector(selector: SBPickerSelector!, selectedValue value: String!, index idx: Int)
    {
        self.btnCourt.setTitle(value, forState: UIControlState.Normal)
        self.courtID = String(self.arrOfCourt.objectAtIndex(idx).valueForKey("CourtId") as! Int)
    }
    
    func pickerSelector(selector: SBPickerSelector!, dateSelected date: NSDate!)
    {
        
        let dateFormat_Credit = NSDateFormatter()
        dateFormat_Credit.dateFormat = "yyyy/MM/dd"
        
        let dateVal_credit :String  = dateFormat_Credit.stringFromDate(date)
        self.btnDate.setTitle(dateVal_credit, forState: UIControlState.Normal)
        
        let formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dt = formatter.stringFromDate(date)
        selectedDate = dt
    }

    @IBAction func btnDoneClick(sender : UIButton)
    {
        //self.lawArea = self.arrOfLawArea.componentsJoinedByString("|")
        
        if (self.btnCourt.titleLabel!.text == NSLocalizedString("Select Court", comment: "comm") ) {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please select Court", comment: "comm"))
            return
        }
        if (self.btnDate.titleLabel!.text == NSLocalizedString("Select Date", comment: "comm") ) {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please select Date", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtClientName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Client Name", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtNoteView.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Notes", comment: "comm"))
            return
        }
        
       if(self.postype == "")
       {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please select type.", comment: "comm"))
            return
        }
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(self.courtID, forKey: "CourtId")
        paramDic.setValue(self.selectedDate, forKey: "Date")
        paramDic.setValue(self.txtClientName.text!, forKey: "ClientName")
        paramDic.setValue(self.txtNoteView.text!, forKey: "Note")
        paramDic.setValue(self.agentID, forKey: "UserId")
        paramDic.setValue(self.postype, forKey: "PostType")
       
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        //API Calling
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Principle/PostProject")!)
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
                            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Project Posted Succesfully.", comment: "comm"))
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            })
        }

    }
    
    //PRAGMA - UITextiew Delegate
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if textView.textColor ==  UIColor.darkGrayColor()
        {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty
        {
            textView.text = NSLocalizedString("Notes", comment: "comm")
            
            textView.textColor =  UIColor.darkGrayColor()
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
