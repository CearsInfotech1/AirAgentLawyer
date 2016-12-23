//
//  MentionDetailViewController.swift
//  AirAgentLawyer
//
//  Created by Admin on 20/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
class MentionDetailViewController: UIViewController {

    @IBOutlet var lblPrincipleName : UILabel!
    @IBOutlet var principleEmail : UILabel!
    @IBOutlet var principleMobile : UILabel!
    @IBOutlet var courtNAme : UILabel!
    @IBOutlet var Clientname : UILabel!
    @IBOutlet var mentionDate : UILabel!
    @IBOutlet var courtAdd1 : UILabel!
    @IBOutlet var courtAdd2 : UILabel!
    @IBOutlet var Description : UILabel!
    @IBOutlet var descView : UIView!
    
    var objOfMention : MentionRequest = MentionRequest()
    var principleObj : PostProjectRequest = PostProjectRequest()
    
    var agentID : String = ""
    var Token : String = ""
    var respone : NSDictionary = NSDictionary()
    var userType : Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
                self.userType = userData_val.valueForKey("UserType") as! Int
            }
        }
        
        self.getDetail()
    }

    func getDetail()
    {
        //API Calling
        var str : String = ""
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        if(self.userType == 1)
        {
            str = "Agent/FullmentionDetail?MentionId="+String(objOfMention.MentionId)
        }
        else if(self.userType == 2)
        {
            str = "Agent/FullmentionDetail?MentionId="+String(principleObj.MentionId)
        }
        
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
                        self.respone = object.valueForKey("Result") as! NSDictionary
                        self.lblPrincipleName.text = NSString(format: "%@ %@", self.respone.valueForKey("P_FirstName") as! String,self.respone.valueForKey("P_LastName") as! String) as String
                        self.principleEmail.text = self.respone.valueForKey("P_Email") as? String
                        self.principleMobile.text = self.respone.valueForKey("P_Mobileno") as? String
                        
                        self.courtNAme.text = self.respone.valueForKey("CourtName") as? String
                        self.Clientname.text = self.respone.valueForKey("ClientName") as? String
                        let formatter : NSDateFormatter = NSDateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let dt = formatter.dateFromString((self.respone.valueForKey("Date") as? String)!)
                        formatter.dateFormat = "dd/MM/yyyy"
                        print(formatter.stringFromDate(dt!))
                        self.mentionDate.text  = formatter.stringFromDate(dt!)
                        
                        self.courtAdd1.text = self.respone.valueForKey("Address1") as? String
                        self.courtAdd2.text = self.respone.valueForKey("Address2") as? String
                        self.Description.text = self.respone.valueForKey("Note") as? String
                        
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

    @IBAction func btnBackClick(sender : UIButton)
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
