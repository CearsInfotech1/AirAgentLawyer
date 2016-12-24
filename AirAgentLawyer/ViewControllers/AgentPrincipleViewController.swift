//
//  AgentPrincipleViewController.swift
//  AirAgentLawyer
//
//  Created by Admin on 22/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class AgentPrincipleViewController: BaseViewController {

    @IBOutlet var btnAgent : UIButton!
    @IBOutlet var btnPrinciple : UIButton!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var tblHome : UITableView!
    @IBOutlet var lblAgent : UILabel!
    @IBOutlet var lblPrinciple : UILabel!
    
    var arrOfMention : NSMutableArray = NSMutableArray()
    var agentID : String = ""
    var Token : String = ""
    var userType : Int!
    var btnClick : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.lblAgent.backgroundColor = Selected_Color
        self.lblPrinciple.backgroundColor = UIColor.clearColor()
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
                self.userType = userData_val.valueForKey("UserType") as! Int
            }
        }
        self.btnClick = "agent"
        self.getMentionRequest()
    }

    @IBAction func btnAgentClick(sender : UIButton)
    {
        if(sender.selected)
        {
        }
        else
        {
//            GlobalClass.sharedInstance.bottomSelectedBorderColorSignup(self.lblAgent)
//            GlobalClass.sharedInstance.bottomBorderColorSignup(self.lblPrinciple)
            self.lblAgent.backgroundColor = Selected_Color
            self.lblPrinciple.backgroundColor = UIColor.clearColor()
            self.lblTitle.text = NSLocalizedString("Agent Mention Request", comment: "comm")
            self.btnClick = "agent"
            self.getMentionRequest()
            
        }
    }
    @IBAction func btnPrincipalClick(sender : UIButton)
    {
        if(sender.selected)
        {
        }
        else
        {
            self.lblPrinciple.backgroundColor = Selected_Color
            self.lblAgent.backgroundColor = UIColor.clearColor()
            self.lblTitle.text = NSLocalizedString("Principal Request Post", comment: "comm")
            self.btnClick = "principal"
            self.getPendingPostRequest()
        }
    }
    
    func getMentionRequest()
    {
        var arrMention = []
        self.arrOfMention = []
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        //API Calling
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let str = "Agent/AgentMentionRequest?AgentId="+self.agentID
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
                        print("dat ",object.valueForKey("Data"))
                        if(!object.valueForKey("Data")!.isKindOfClass(NSNull))
                        {
                            print("not null")
                            arrMention = object.valueForKey("Data") as! NSArray
                            for i in 0  ..< arrMention.count
                            {
                                let mentionObj : MentionRequest = MentionRequest()
                                
                                mentionObj.AgentId = arrMention[i].valueForKey("AgentId") as? Int
                                mentionObj.ClientName = arrMention[i].valueForKey("ClientName") as? String ?? ""
                                mentionObj.CourtAddress = arrMention[i].valueForKey("CourtAddress") as? String ?? ""
                                mentionObj.CourtCity = arrMention[i].valueForKey("CourtCity") as? String ?? ""
                                mentionObj.CourtName = arrMention[i].valueForKey("CourtName") as? String ?? ""
                                mentionObj.MentionDate = arrMention[i].valueForKey("MentionDate") as? String ?? ""
                                mentionObj.MentionId = arrMention[i].valueForKey("MentionId") as? Int
                                mentionObj.Principleid = arrMention[i].valueForKey("Principleid") as? Int
                                mentionObj.Status = arrMention[i].valueForKey("Status") as? Int
                                
                                self.arrOfMention.addObject(mentionObj)
                            }
                            self.tblHome.reloadData()
                        }
                        else
                        {
                            print("no data availabel")
                            self.tblHome.reloadData()
                        }
                        
                    }
                }
                else
                {
                    GlobalClass.sharedInstance.stopIndicator()
                    if(!object!.valueForKey("Data")!.isKindOfClass(NSNull))
                    {
                        print("not null")
                    }
                    else
                    {
                        print("no data availabel")
                    }
                    self.tblHome.reloadData()
                }
            })
        }
    }

    func getPendingPostRequest()
    {
        self.arrOfMention = []
        var arrPost = []
        
        if(!GlobalClass.sharedInstance.isConnectedToNetwork()) {
            GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("No Internet Connection!", comment: "comm"))
            return
        }
        
        //API Calling
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let str = "Principle/PendingPost?UserId="+self.agentID
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
                        print("response object principle",object)
                        print("dat ",object.valueForKey("Data"))
                        if(!object.valueForKey("Data")!.isKindOfClass(NSNull))
                        {
                            print("not null")
                            arrPost = object.valueForKey("Data") as! NSArray
                            for i in 0  ..< arrPost.count
                            {
                                let postPrjctObj : PostProjectRequest = PostProjectRequest()
                                
                                postPrjctObj.A_Address = arrPost[i].valueForKey("A_Address") as? String ?? ""
                                postPrjctObj.A_Email = arrPost[i].valueForKey("A_Email") as? String ?? ""
                                postPrjctObj.A_FirstName = arrPost[i].valueForKey("A_FirstName") as? String ?? ""
                                postPrjctObj.A_MobileNo = (arrPost[i].valueForKey("A_MobileNo") as? String ?? "")!
                                postPrjctObj.Address = arrPost[i].valueForKey("Address") as? String ?? ""
                                postPrjctObj.CourtName = arrPost[i].valueForKey("CourtName") as? String ?? ""
                                postPrjctObj.Date = arrPost[i].valueForKey("Date") as? String ?? ""
                                postPrjctObj.Email = arrPost[i].valueForKey("Email") as? String ?? ""
                                postPrjctObj.FirstName = arrPost[i].valueForKey("FirstName") as? String ?? ""
                                postPrjctObj.MentionId = (arrPost[i].valueForKey("MentionId") as? Int)!
                                postPrjctObj.MobileNo = (arrPost[i].valueForKey("MobileNo") as? String ?? "")!
                                postPrjctObj.Status = (arrPost[i].valueForKey("Status") as? Int)!
                                
                                self.arrOfMention.addObject(postPrjctObj)
                            }
                            self.tblHome.reloadData()
                        }
                        else
                        {
                            print("no data availabel")
                            self.tblHome.reloadData()
                        }
                        
                    }
                }
                else
                {
                    GlobalClass.sharedInstance.stopIndicator()
                    if(!object!.valueForKey("Data")!.isKindOfClass(NSNull))
                    {
                        print("not null")
                    }
                    else
                    {
                        print("no data availabel")
                    }
                    self.tblHome.reloadData()
                }
            })
        }
    }
    
    //MARK : tableview delegate and datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(self.arrOfMention.count > 0)
        {
            return self.arrOfMention.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.arrOfMention.count > 0)
        {
            return 82
        }
        else
        {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(self.arrOfMention.count > 0)
        {
            let cell:HomeCell = tableView.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
            
            if(self.btnClick == "agent")
            {
                let mentionObj = self.arrOfMention.objectAtIndex(indexPath.row) as! MentionRequest
                print("entire obj",mentionObj)
                print(mentionObj.CourtAddress)
                
                cell.selectionStyle = .None
                
                cell.lblTitle.text = mentionObj.CourtName
                cell.lblSubtitle.text = mentionObj.ClientName
                cell.lblLocation.text = mentionObj.CourtAddress
                
                let formatter : NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let dt = formatter.dateFromString(mentionObj.MentionDate)
                formatter.dateFormat = "dd/MM/yyyy"
                print(formatter.stringFromDate(dt!))
                cell.lblDate.text = formatter.stringFromDate(dt!)
            }
            else if(self.btnClick == "principal")
            {
                let postObj = self.arrOfMention.objectAtIndex(indexPath.row) as! PostProjectRequest
                
                cell.selectionStyle = .None
                
                cell.lblTitle.text = postObj.CourtName
                cell.lblSubtitle.text = postObj.A_FirstName
                cell.lblLocation.text = postObj.Address
                
                let formatter : NSDateFormatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let dt = formatter.dateFromString(postObj.Date)
                formatter.dateFormat = "dd/MM/yyyy"
                print(formatter.stringFromDate(dt!))
                cell.lblDate.text = formatter.stringFromDate(dt!)
            }
            return cell
        }
        else
        {
            self.tblHome.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
            cell.backgroundColor = UIColor.clearColor()
            if(self.btnClick == "agent")
            {
                cell.textLabel?.text = NSLocalizedString("Request Not Available.", comment: "comm")
            }
            else if(self.btnClick == "principal")
            {
                cell.textLabel?.text = NSLocalizedString("Pending Post Not Available.", comment: "comm")
            }
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
