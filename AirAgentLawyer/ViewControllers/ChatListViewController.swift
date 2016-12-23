//
//  ChatListViewController.swift
//  AirAgentLawyer
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class ChatListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var agentID : String = ""
    var arrOfChatList : NSMutableArray = NSMutableArray()
    var Token : String = ""
    
    @IBOutlet var tblChatList: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.agentID = String(userData_val.valueForKey("userid") as! Int)
                self.Token = userData_val.valueForKey("Token") as! String
            }
        }
        
        tblChatList.delegate = self
        tblChatList.dataSource = self
        tblChatList.tableFooterView = UIView(frame: CGRect.zero)
        
        self.getChatListRequest()
    }
    
    func getChatListRequest()
    {
        //API Calling
        GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
        
        let str = "Profile/GetMentionByUserid?UserId="+self.agentID
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
                        let tempDic: NSDictionary = CommonClass.sharedInstance().dictionaryByReplacingNullsWithStrings(object as! [NSObject : AnyObject])
                        
                        if(tempDic["IsSuccess"] as! Bool == true)
                        {
                            print("dat ",tempDic["Data"])
                            if tempDic["Data"] != nil {
                                let tempArr: NSArray = NSArray(array:tempDic["Data"] as! NSArray)
                                self.arrOfChatList = NSMutableArray(array: tempArr)
                            }
                        }
                    }
                }
                else
                {
                    GlobalClass.sharedInstance.stopIndicator()
                }
                self.tblChatList.reloadData()
            })
        }
    }
    
    //MARK : tableview delegate and datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(self.arrOfChatList.count > 0)
        {
            return self.arrOfChatList.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.arrOfChatList.count > 0) {
            return 74
        }
        else {
            return 40
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(self.arrOfChatList.count > 0) {
            
            let cell:ChatListCell = tableView.dequeueReusableCellWithIdentifier("ChatListCell") as! ChatListCell
            
            let Obj: NSDictionary = self.arrOfChatList.objectAtIndex(indexPath.row) as! NSDictionary
            
            cell.lblTitle.text = Obj["ClientName"] as? String
            cell.lblMsg.text = Obj["Note"] as? String
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dt = formatter.dateFromString(Obj["MentionDate"] as! String)
            formatter.dateFormat = "dd/MM/yyyy"
            cell.lblDate.text = formatter.stringFromDate(dt!)
            
            cell.imgCell.layer.cornerRadius = cell.imgCell.frame.size.height / 2.0
            cell.imgCell.clipsToBounds = true
            cell.imgCell.sd_setImageWithURL(NSURL(string: (Obj["profilephoto"] as! String)), placeholderImage: UIImage(named: "ic_login_logo"))
            
            cell.selectionStyle = .None
            return cell
        }
        else {
            
            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            
            let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
            cell.backgroundColor = UIColor.clearColor()
            cell.textLabel?.text = NSLocalizedString("Chat Not Available.", comment: "comm")
            cell.textLabel?.textColor = UIColor(red: 57/255, green: 80/255, blue: 99/255, alpha: 1.0)
            cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let obj: NSDictionary = self.arrOfChatList.objectAtIndex(indexPath.row) as! NSDictionary
        
        let messageView: MessageViewController = MessageViewController()
        messageView.receiverDict = NSMutableDictionary(dictionary: ["contactname":obj["ClientName"] as! String,"toId": String(obj["MentionId"] as! Int)])
        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                messageView.userDict = NSMutableDictionary(dictionary: ["contactname":userData_val["Token"] as! String, "token":userData_val["Token"] as! String,"userid": String(userData_val["userid"] as! Int)])
            }
        }
        
        self.navigationController?.pushViewController(messageView, animated: true)
    }

    @IBAction func btnBack(sender : UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
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
