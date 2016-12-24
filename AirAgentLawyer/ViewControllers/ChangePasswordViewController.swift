//
//  ChangePasswordViewController.swift
//  AirAgentLawyer
//
//  Created by Admin on 16/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet var txtOldPass : UITextField!
    @IBOutlet var txtNewPass : UITextField!
    @IBOutlet var txtConfirmPass : UITextField!
    var agentID : String = ""
    var Token : String = ""
    
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
    }

    @IBAction func btnDoneClick(sender : UIButton)
    {
        if NSString(format:"%@", txtOldPass.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter old Password", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtNewPass.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Password", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtConfirmPass.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter confirm Password", comment: "comm"))
            return
        }
        
        if(self.txtNewPass.text != self.txtConfirmPass.text)
        {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Confirm password mismatch.", comment: "comm"))
            return
        }
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(self.agentID, forKey: "UserId")
        paramDic.setValue(self.txtOldPass.text!, forKey: "OldPassword")
        paramDic.setValue(self.txtNewPass.text!, forKey: "NewPassword")
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        
        //API Calling
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Profile/ChangePassword")!)
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
                           GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Password Change Successfully", comment: "comm"))
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func clkBack(sender: UIButton)
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
