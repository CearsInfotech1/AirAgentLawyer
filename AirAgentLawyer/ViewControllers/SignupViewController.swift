//
//  SignupViewController.swift
//  AirAgentLawyer
//
//  Created by Apple on 24/11/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class TitleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var backView : UIView!
    @IBOutlet var titleName : UILabel!
    @IBOutlet var btnSelect : UIButton!
}

class SignupViewController: UIViewController, TpKeyboardDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
  
    @IBOutlet var txtFname : UITextField!
    @IBOutlet var txtlname : UITextField!
    @IBOutlet var txtFirmName : UITextField!
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtConfirmEmail : UITextField!
    @IBOutlet var txtMobile : UITextField!
    @IBOutlet var txtPass : UITextField!
    @IBOutlet var txtState : UITextField!
    @IBOutlet var txtTown : UITextField!
    @IBOutlet var txtStreet : UITextField!
    @IBOutlet var txtPostCode : UITextField!
    @IBOutlet var txtBSBNumber : UITextField!
    @IBOutlet var txtAccount : UITextField!
    @IBOutlet var txtCardNumber : UITextField!
    @IBOutlet var txtExpiry : UITextField!
    @IBOutlet var txtCVV : UITextField!
    
    @IBOutlet var txtViewAddress: UITextView!
    @IBOutlet var txtViewOffice: UITextView!
  
    @IBOutlet var titleCollection : UICollectionView!
    @IBOutlet var heightOfCollectionView : NSLayoutConstraint!
    
    @IBOutlet var btnCheck: UIButton!
    @IBOutlet var btnAgent: UIButton!
    @IBOutlet var btnPrincipal: UIButton!
    @IBOutlet var btnBoth: UIButton!
    @IBOutlet var accountView : UIView!
    @IBOutlet var heightOfAccountView : NSLayoutConstraint!
    
    @IBOutlet var BSBtView : UIView!
    @IBOutlet var heightOfBSBView : NSLayoutConstraint!

    @IBOutlet var viewOfCategory : UIView!
    @IBOutlet var heightOfcatView : NSLayoutConstraint!
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var btnDone : UIButton!
    
    @IBOutlet var lblTerms : UILabel!
    @IBOutlet var lblAgree : UILabel!
    
    @IBOutlet var heightOfPass : NSLayoutConstraint!
    
    var arrOfCategory : NSArray = NSArray()
    var arrOfCategoryName : NSMutableArray = NSMutableArray()
    var lawArea : String = ""
    var userType : String = ""
    var arrOfLawArea : NSMutableArray = NSMutableArray()
    var fromEditProfile : String = ""
    var dictOfUser : NSDictionary = NSDictionary()
    
    var lawAreaArr : NSMutableArray = NSMutableArray()
    var Token : String = ""
    var agentID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(fromEditProfile == "yes")
        {
            print("profile dictionary",self.dictOfUser)

            let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
            if let userData = user_Data {
                let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
                
                if let userData_val = userObj {
                    
                    self.agentID = String(userData_val.valueForKey("userid") as! Int)
                    self.Token = userData_val.valueForKey("Token") as! String
                }
            }
            heightOfCollectionView.constant = 0
            self.titleLabel.text = NSLocalizedString("Edit Profile", comment: "comm")
            self.lblAgree.hidden = true
            self.lblTerms.hidden = true
            self.btnCheck.hidden = true
            
            self.txtFname.text = self.dictOfUser.valueForKey("FirstName") as? String
            self.txtlname.text = self.dictOfUser.valueForKey("LastName") as? String
            self.txtFirmName.text = self.dictOfUser.valueForKey("FirmName") as? String
            self.txtState.text = self.dictOfUser.valueForKey("State") as? String
            self.txtTown.text = self.dictOfUser.valueForKey("Town") as? String
            self.txtStreet.text = self.dictOfUser.valueForKey("Street") as? String
            self.txtPostCode.text = self.dictOfUser.valueForKey("Postcode") as? String
            self.txtEmail.text = self.dictOfUser.valueForKey("Email") as? String
            self.txtConfirmEmail.text = self.dictOfUser.valueForKey("Email") as? String
            self.txtMobile.text = self.dictOfUser.valueForKey("MobileNo") as? String
            self.heightOfPass.constant = 0
            self.userType = String(self.dictOfUser.valueForKey("UserType") as! Int)
            
            if(self.dictOfUser.valueForKey("UserType") as! Int == 1)
            {
                self.heightOfAccountView.constant = 0
                self.accountView.hidden = true
                self.txtBSBNumber.text = self.dictOfUser.valueForKey("BSB") as? String
                self.txtAccount.text = self.dictOfUser.valueForKey("Account") as? String
            }
            else if(self.dictOfUser.valueForKey("UserType") as! Int == 2)
            {
                self.BSBtView.hidden = true
                self.heightOfBSBView.constant = 0
                self.txtCardNumber.text = self.dictOfUser.valueForKey("CardNumber") as? String
                self.txtExpiry.text = self.dictOfUser.valueForKey("Expiry") as? String
                self.txtCVV.text = self.dictOfUser.valueForKey("CVV") as? String
            }
            else if(self.dictOfUser.valueForKey("UserType") as! Int == 3)
            {
                self.accountView.hidden = false
                self.BSBtView.hidden = false
                self.txtBSBNumber.text = self.dictOfUser.valueForKey("BSB") as? String
                self.txtAccount.text = self.dictOfUser.valueForKey("Account") as? String
                self.txtCardNumber.text = self.dictOfUser.valueForKey("CardNumber") as? String
                self.txtExpiry.text = self.dictOfUser.valueForKey("Expiry") as? String
                self.txtCVV.text = self.dictOfUser.valueForKey("CVV") as? String

            }
            self.viewOfCategory.hidden = true
            self.heightOfcatView.constant = 0
            
            if(!self.dictOfUser.valueForKey("LawArea")!.isKindOfClass(NSNull))
            {
                let lowArea : NSString = self.dictOfUser.valueForKey("LawArea") as! NSString
                self.lawAreaArr = (lowArea.componentsSeparatedByString("|") as? NSMutableArray)!
                for i in 0  ..< self.lawAreaArr.count
                {
                    self.arrOfLawArea.addObject(Int(self.lawAreaArr[i] as! String)!)
                }
                
                print("arr of low area",self.lawAreaArr)
                print("arr of arr low arear",self.arrOfLawArea)
            }
            
            
        }
        else
        {
            btnCheck.selected = false

            GlobalClass.sharedInstance.bottomSelectedBorderColorSignup(self.btnAgent)
            self.userType = "1"
            self.accountView.hidden = true
            self.heightOfAccountView.constant = 0
            heightOfCollectionView.constant = 0
        }
        self.getCategory()
    }
    
    func getCategory()
    {
//        if(self.fromEditProfile == "yes")
//        {
//            
//        }
//        else
//        {
//            self.arrOfLawArea = []
//        }
        self.arrOfCategory = []
        self.arrOfCategoryName = []
        
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
        cell.titleName.text = self.arrOfCategoryName[indexPath.row] as? String
        
        for i in 0 ..< self.lawAreaArr.count
        {
            if(self.arrOfCategory.objectAtIndex(indexPath.row).valueForKey("CategoryId") as?
                Int == Int(self.lawAreaArr[i] as! String))
            {
                print("set it to selected")
                cell.selected = true
                cell.btnSelect.selected = true
            }
        }

        return cell
    }
    
    func selectCat(sender : UIButton)
    {
        print("tag val",sender.tag)
        print("arr of category",self.arrOfCategory)
        print("arr of law area",self.arrOfLawArea.count)
        
        if(sender.selected)
        {
            sender.selected = false
            if(self.arrOfLawArea.count > 0)
            {
                for i in 0 ..< self.arrOfLawArea.count
                {
                    if(self.arrOfCategory.objectAtIndex(sender.tag).valueForKey("CategoryId") as!
                            Int == self.arrOfLawArea[i] as! Int)
                        {
                            self.arrOfLawArea.removeObjectAtIndex(i)
                            return

                        }
                    }
            }
        }
        else
        {
            sender.selected = true

          self.arrOfLawArea.addObject(self.arrOfCategory[sender.tag].valueForKey("CategoryId")!)

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
    
    @IBAction func clkBack(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func clkTermsCheck(sender: UIButton) {
        
        if btnCheck.selected == true {
            btnCheck.selected = false
        }
        else {
            btnCheck.selected = true
        }
    }
    
    @IBAction func clkDone(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK : TPKeyBoardDelegate
    
    func willTextFieldBeginEditing(textField: AnyObject!) -> Bool {
        
        if textField.isKindOfClass(UITextView.classForCoder()) {
            
            let txtView: UITextView = textField as! UITextView
            
            if txtView == txtViewAddress {
            
                if txtView.text == "Address" {
                    txtViewAddress.text = ""
                    txtViewAddress.textColor = UIColor.blackColor()
                }
            }
            if txtView == txtViewOffice {
                
                if txtView.text == "Office" {
                    txtViewOffice.text = ""
                    txtViewOffice.textColor = UIColor.blackColor()
                }
            }
        }
        
        return true
    }
    
    func didTextFieldEditingFinish(textField: AnyObject!) {
        
        if textField.isKindOfClass(UITextView.classForCoder()) {
            
            let txtView: UITextView = textField as! UITextView
            
            if txtView == txtViewAddress {
                
                if txtView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                    txtViewAddress.text = "Address"
                    txtViewAddress.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 198/255.0, alpha: 1.0)
                }
            }
            if txtView == txtViewOffice {
                
                if txtView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "" {
                    txtViewOffice.text = "Office"
                    txtViewOffice.textColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 198/255.0, alpha: 1.0)
                }
            }
        }
    }
  
    func shouldChangeTextViewText(textView: AnyObject!, range range1: NSRange, text str1: String!) -> Bool {
        return true
    }

    @IBAction func btnAgentClick(sender : UIButton)
    {
        if(sender.selected)
        {
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnAgent)
            
        }
        else
        {
            self.userType = "1"
            self.accountView.hidden = true
            self.heightOfAccountView.constant = 0
            self.BSBtView.hidden = false
            self.heightOfBSBView.constant = 172
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnPrincipal)
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnBoth)
            GlobalClass.sharedInstance.bottomSelectedBorderColorSignup(self.btnAgent)
        }
    }
    @IBAction func btnPrincipalClick(sender : UIButton)
    {
        if(sender.selected)
        {
            
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnPrincipal)
           

        }
        else
        {
            self.userType = "2"
            self.BSBtView.hidden = true
            self.heightOfBSBView.constant = 0
            self.accountView.hidden = false
            self.heightOfAccountView.constant = 108
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnAgent)
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnBoth)
            GlobalClass.sharedInstance.bottomSelectedBorderColorSignup(self.btnPrincipal)
        }
    }
    @IBAction func btnBothClick(sender : UIButton)
    {
        if(sender.selected)
        {
           
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnBoth)

        }
        else
        {
            self.userType = "3"
            self.BSBtView.hidden = false
            self.heightOfBSBView.constant = 172
            self.accountView.hidden = false
            self.heightOfAccountView.constant = 108
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnAgent)
            GlobalClass.sharedInstance.bottomBorderColorSignup(self.btnPrincipal)
            GlobalClass.sharedInstance.bottomSelectedBorderColorSignup(self.btnBoth)
        }
    }
    
    @IBAction func btnSignupClick(sender : UIButton)
    {
        if(self.fromEditProfile == "yes")
        {
            print("call edit profile api",self.arrOfLawArea)
            
            self.lawArea = self.arrOfLawArea.componentsJoinedByString("|")
            print("law area value",lawArea)
            
            GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
            
            let paramDic : NSMutableDictionary = NSMutableDictionary()
            paramDic.setValue(self.agentID, forKey: "UserId")
            paramDic.setValue(self.txtFname.text!, forKey: "FirstName")
            paramDic.setValue(self.txtlname.text!, forKey: "LastName")
            paramDic.setValue(self.txtFirmName.text!, forKey: "FirmName")
            paramDic.setValue(self.txtState.text!, forKey: "State")
            paramDic.setValue(self.txtTown.text!, forKey: "Town")
            paramDic.setValue(self.txtStreet.text!, forKey: "Street")
            paramDic.setValue(self.txtPostCode.text!, forKey: "Postcode")
            paramDic.setValue(self.txtMobile.text!, forKey: "MobileNo")
            paramDic.setValue(self.txtEmail.text!, forKey: "Email")
            
            if(self.userType == "1" || self.userType == "3")
            {
                paramDic.setValue(self.txtBSBNumber.text!, forKey: "BSB")
                paramDic.setValue(self.txtAccount.text!, forKey: "Account")
            }
            else
            {
                paramDic.setValue("", forKey: "BSB")
                paramDic.setValue("", forKey: "Account")
            }
            
            if(self.userType == "2" || self.userType == "3")
            {
                paramDic.setValue(self.txtCardNumber.text!, forKey: "CardNumber")
                paramDic.setValue(self.txtExpiry.text!, forKey: "Expiry")
                paramDic.setValue(self.txtCVV.text!, forKey: "CVV")
            }
            else
            {
                paramDic.setValue("", forKey: "CardNumber")
                paramDic.setValue("", forKey: "Expiry")
                paramDic.setValue("", forKey: "CVV")
                
            }
           
            paramDic.setValue(self.lawArea, forKey: "LawArea")
            
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print("json string",jsonString)
            
            
            //API Calling
            
            let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"/Profile/UpdateProfile")!)
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
                                GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Profile Succesfully.", comment: "comm"))
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                })
            }
        }
        else
        {
            
            self.lawArea = self.arrOfLawArea.componentsJoinedByString("|")
            print("law area value",lawArea)
            
            GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
            
            let paramDic : NSMutableDictionary = NSMutableDictionary()
             paramDic.setValue(0, forKey: "UserId")
             paramDic.setValue(self.txtFname.text!, forKey: "FirstName")
             paramDic.setValue(self.txtlname.text!, forKey: "LastName")
             paramDic.setValue(self.txtFirmName.text!, forKey: "FirmName")
             paramDic.setValue(self.txtState.text!, forKey: "State")
             paramDic.setValue(self.txtTown.text!, forKey: "Town")
             paramDic.setValue(self.txtStreet.text!, forKey: "Street")
             paramDic.setValue(self.txtPostCode.text!, forKey: "Postcode")
             paramDic.setValue(self.txtMobile.text!, forKey: "MobileNo")
             paramDic.setValue(self.txtEmail.text!, forKey: "Email")
            
             if(self.userType == "1" || self.userType == "3")
             {
                paramDic.setValue(self.txtBSBNumber.text!, forKey: "BSB")
                paramDic.setValue(self.txtAccount.text!, forKey: "Account")
             }
             else
             {
                paramDic.setValue("", forKey: "BSB")
                paramDic.setValue("", forKey: "Account")
             }
            
             if(self.userType == "2" || self.userType == "3")
             {
                paramDic.setValue(self.txtCardNumber.text!, forKey: "CardNumber")
                paramDic.setValue(self.txtExpiry.text!, forKey: "Expiry")
                paramDic.setValue(self.txtCVV.text!, forKey: "CVV")
             }
             else
             {
                paramDic.setValue("", forKey: "CardNumber")
                paramDic.setValue("", forKey: "Expiry")
                paramDic.setValue("", forKey: "CVV")

             }
             paramDic.setValue(self.userType, forKey: "UserType")
             paramDic.setValue(self.lawArea, forKey: "LawArea")
             paramDic.setValue(self.txtPass.text!, forKey: "Password")

            let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print("json string",jsonString)
            
            
            //API Calling
            
            let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Register/RegisterUser")!)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
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
                                GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Registration Succesfully.", comment: "comm"))
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
