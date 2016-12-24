//
//  LoginViewController.swift
//  AirAgentLawyer
//
//  Created by Apple on 22/11/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, TpKeyboardDelegate {
    
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clkLogin(sender: UIButton) {
        
        self.view.endEditing(true)
        
        if NSString(format:"%@", txtUsername.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Email", comment: "comm"))
            return
        }
        
        if (GlobalClass.isValidEmail(self.txtUsername.text!) == false)
        {
             GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter valid Email", comment: "comm"))
            return
        }
        
        if NSString(format:"%@", txtPassword.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())).length == 0 {
            GlobalClass.sharedInstance.showAlert(NSLocalizedString("Message", comment: "comm"), msg: NSLocalizedString("Please enter Password", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(self.txtUsername.text!, forKey: "Email")
        paramDic.setValue(self.txtPassword.text!, forKey: "Password")
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        //API Calling
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Login/UserLogin")!)
        print("request",request)
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
                        if(object.valueForKey("IsSuccess") as! Bool == true)
                        {
                            let userData = NSKeyedArchiver.archivedDataWithRootObject((object.valueForKey("Result"))!)
                            
                            NSUserDefaults.standardUserDefaults().setObject(userData, forKey: "USER_OBJECT")
                            
                            let result = object.valueForKey("Result") as! NSDictionary
                            print("user type value ",result.valueForKey("UserType"))
                            if(result.valueForKey("UserType") as! Int == 1 || result.valueForKey("UserType") as! Int == 2)
                            {
                                let vcObj = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                                self.navigationController?.pushViewController(vcObj, animated: true)
                            }
                            else if(result.valueForKey("UserType") as! Int == 3)
                            {
                                let vcObj = self.storyboard?.instantiateViewControllerWithIdentifier("AgentPrincipleViewController") as! AgentPrincipleViewController
                                self.navigationController?.pushViewController(vcObj, animated: true)
                            }
                        }
                    }
                }
            })
        }

    }
    
    
    @IBAction func clkGoogleLogin(sender: UIButton) {
        
        self.view.endEditing(true)
        
        let vcObj = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vcObj, animated: true)
    }
    
    @IBAction func clkForgotPassword(sender: UIButton) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func clkSignup(sender: UIButton) {
        
        self.view.endEditing(true)
        
        let vcObj = self.storyboard?.instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(vcObj, animated: true)
    }
    
    func didTextFieldEditingFinish(textField: AnyObject!) {
        
    }
    
    //MARK : TPKeyBoardDelegate
    
    func willTextFieldBeginEditing(textField: AnyObject!) -> Bool {
        return true
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
