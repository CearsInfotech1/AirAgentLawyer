//
//  ProfileViewController.swift
//  AirAgentLawyer
//
//  Created by cears infotech on 11/26/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var lblFname : UILabel!
    @IBOutlet var lblLname : UILabel!
    @IBOutlet var lblAdd : UILabel!
    @IBOutlet var lblOffice : UILabel!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblMobile : UILabel!
    @IBOutlet var imgProfile : UIImageView!
    
    var agentID : String = ""
    var Token : String = ""
    var ResultDic : NSDictionary = NSDictionary()
    var base64String : String = ""
    var imgName : String  = ""
    var imageData : NSData = NSData()
    let imagePickerController: UIImagePickerController = UIImagePickerController()
    var btnImageClick : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePickerController.delegate = self
        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
            }
        }
        self.imgProfile.layer.cornerRadius = (self.imgProfile.frame.size.width/2)
        self.imgProfile.layer.masksToBounds = true
        
    }

    override func viewWillAppear(animated: Bool)
    {
        if(btnImageClick == "yes")
        {
            
        }
        else
        {
            self.getProfileData()
        }
    }
    @IBAction func clkBack(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func getProfileData()
    {
        //API Calling
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let str = "Profile/GetUserById?UserId="+self.agentID
        
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
                        print("response object",object)
                        print("dat ",object.valueForKey("Result"))
                        var address  : String = ""
                        self.ResultDic = object.valueForKey("Result") as! NSDictionary
                        self.lblFname.text = self.ResultDic.valueForKey("FirstName") as? String
                        self.lblLname.text = self.ResultDic.valueForKey("LastName") as? String
                        if(!self.ResultDic.valueForKey("Street")!.isKindOfClass(NSNull))
                        {
                            address = self.ResultDic.valueForKey("Street") as! String
//                            self.lblAdd.text = self.ResultDic.valueForKey("LastName") as? String
                        }
                        if(!self.ResultDic.valueForKey("Town")!.isKindOfClass(NSNull))
                        {
                            address = address + "," + (self.ResultDic.valueForKey("Town") as! String)
                        }
                        if(!self.ResultDic.valueForKey("State")!.isKindOfClass(NSNull))
                        {
                            address = address + "," + (self.ResultDic.valueForKey("State") as! String)
                        }
                        if(address != "")
                        {
                            self.lblAdd.text = address

                        }
                        else
                        {
                            self.lblAdd.text = NSLocalizedString("Address Not Available.", comment: "comm")
                        }
                        self.lblEmail.text =  self.ResultDic.valueForKey("Email") as? String
                        
                        if(!self.ResultDic.valueForKey("OfficeAddress")!.isKindOfClass(NSNull))
                        {
                           self.lblOffice.text = self.ResultDic.valueForKey("OfficeAddress") as? String
                        }
                        else
                        {
                            self.lblOffice.text = "-"
                        }
                        self.imgProfile.sd_setImageWithURL(NSURL(string : (self.ResultDic.valueForKey("Photo") as? String)!), placeholderImage: UIImage(named: "ic_login_logo"))
                        self.lblMobile.text = self.ResultDic.valueForKey("MobileNo") as? String
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
    
    @IBAction func btnEditClick(sender : UIButton)
    {
        let editProfile = self.storyboard?.instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
        editProfile.fromEditProfile = "yes"
        editProfile.dictOfUser = self.ResultDic
        self.navigationController?.pushViewController(editProfile, animated: true)
    }
    
    @IBAction func btnChangePassClick(sender : UIButton)
    {
        let changePass = self.storyboard?.instantiateViewControllerWithIdentifier("ChangePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(changePass, animated: true)
    }
    
    @IBAction func btnCameraClick(sender : UIButton)
    {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: NSLocalizedString("Set Profile", comment: "comment"), message: "", preferredStyle: .ActionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "comment"), style: .Cancel) { action -> Void in
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose From Gallery", comment: "comment"), style: .Default)
        { action -> Void in
            
            self.imagePickerController.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePickerController, animated: true, completion: {() -> Void in
            })
        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose From Camera", comment: "comment"), style: .Default)
        { action -> Void in
            
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
            {
                self.imagePickerController.sourceType = .Camera
                
                self.presentViewController(self.imagePickerController, animated: true, completion: {() -> Void in
                })
            }
            else
            {
                GlobalClass.sharedInstance.showAlert(APP_Title, msg: (NSLocalizedString("You don't have camera", comment: "comment")))
            }
            
        }
        actionSheetControllerIOS8.addAction(deleteActionButton)
        self.presentViewController(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    //PickerView Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imgProfile.image = pickedImage
            let imageData : NSData = UIImageJPEGRepresentation(pickedImage, 0.5)!
            self.imageData = imageData
            let imageName = NSUUID().UUIDString
            self.imgName = imageName
            btnImageClick = "yes"
            self.uploadPic()
        }
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadPic()
    {
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
      
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
      
        self.base64String = self.imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    
        let paramDic : NSMutableDictionary = NSMutableDictionary()
        paramDic.setValue(self.agentID, forKey: "UserId")
        paramDic.setValue(self.imgName, forKey: "FileName")
        paramDic.setValue(self.base64String, forKey: "ImageStr")
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print("json string",jsonString)
        
        
        //API Calling
        
        let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Profile/UploadImage")!)
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
                            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Profile Pic Update Successfully", comment: "comm"))
                        }
                    }
                }
            })
        }

    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        picker.dismissViewControllerAnimated(true, completion: nil)
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
