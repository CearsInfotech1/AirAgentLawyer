//
//  PopupViewController.swift
//  AirAgentLawyer
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController, TpKeyboardDelegate {
    
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtViewDesc: UITextView!

    var objData : MentionRequest = MentionRequest()
    
    var userDict: NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnClose.layer.borderColor = UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 1.0).CGColor
        btnClose.layer.borderWidth = 1.0
        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                print("userobject : ", userData_val)
                userDict = NSMutableDictionary(dictionary: userData_val as! NSDictionary)
            }
        }
    }
    
    
    //MARK: Close clicked
    @IBAction func btnCloseClick(sender : UIButton) {
        
        self.view.endEditing(true)
        NSNotificationCenter.defaultCenter().postNotificationName("didPopupClose", object: nil)
    }
    
    //MARK: Submit clicked
    @IBAction func btnSubmitClick(sender : UIButton) {
        self.view.endEditing(true)
        self.submitMethod()
    }
    
    
    func submitMethod() {
        
        if NSString(format:"%@", txtTitle.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Title", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtViewDesc.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) == "Description" {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Description", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(String(userDict["userid"] as! Int), forKey: "AgentId")
        paramDic.setValue(String(objData.Principleid), forKey: "PrincipleId")
        paramDic.setValue(String(objData.MentionId), forKey: "MentionId")
        paramDic.setValue(self.txtTitle.text!, forKey: "Title")
        paramDic.setValue(self.txtViewDesc.text!, forKey: "Detail")
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        //API Calling
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Agent/SubmitOutCome")!)
        print("request",request)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(userDict["Token"] as! String, forHTTPHeaderField: "Token")
        request.addValue(String(userDict["userid"] as! Int), forHTTPHeaderField: "UserId")
        
        GlobalClass.sharedInstance.post(request, params: jsonString) { (success, object) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("obj",object)
                GlobalClass.sharedInstance.stopIndicator()
                if success {
                    
                    GlobalClass.sharedInstance.stopIndicator()
                    
                    if let object = object {
                        
                        if(object.valueForKey("IsSuccess") as! Bool == true)
                        {
                            NSNotificationCenter.defaultCenter().postNotificationName("didPopupClose", object: nil)
                            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Outcome is submitted successfully.", comment: "comm"))
                        }
                        else {
                            if object.valueForKey("Message") != nil {
                                
                                if !object.valueForKey("Message")!.isKindOfClass(NSNull) {
                                    
                                    NSNotificationCenter.defaultCenter().postNotificationName("didPopupClose", object: nil)
                                    GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString(object.valueForKey("Message") as! String, comment: "comm"))
                                }
                                else {
                                    GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Problem occurred while processing your request.", comment: "comm"))
                                }
                            }
                            else {
                                GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Problem occurred while processing your request.", comment: "comm"))
                            }
                        }
                    }
                    else {
                        GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Problem occurred while processing your request.", comment: "comm"))
                    }
                }
                else {
                    GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Problem occurred while processing your request.", comment: "comm"))
                }
            })
        }
    }
    
    
    func willTextFieldBeginEditing(textField: AnyObject!) -> Bool {
        
        if textField is UITextView {
            
            if NSString(format:"%@", txtViewDesc.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) == "Description" {
                txtViewDesc.text = ""
                txtViewDesc.textColor = UIColor.blackColor()
            }
        }
        
        return true
    }
    
    
    func didTextFieldEditingFinish(textField: AnyObject!) {
        
        if textField is UITextView {
            
            if NSString(format:"%@", txtViewDesc.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) == "" {
                txtViewDesc.text = "Description"
                txtViewDesc.textColor = UIColor(red: 190/255.0, green: 190/255.0, blue: 190/255.0, alpha: 1.0)
            }
        }
    }
    
    
    func shouldChangeTextViewText(textView: AnyObject!, range range1: NSRange, text str1: String!) -> Bool {
        return true
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
