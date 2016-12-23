//
//  PrincipleDetailViewController.swift
//  AirAgentLawyer
//
//  Created by Admin on 22/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class PrincipleDetailViewController: UIViewController, UITableViewDataSource , UITableViewDelegate {

    @IBOutlet var tblDetail: UITableView!
    
    var postRequest : PostProjectRequest = PostProjectRequest()
    var statusType : Int!
    var userDict: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblDetail.delegate = self
        tblDetail.dataSource = self
        tblDetail.tableFooterView = UIView(frame: CGRect.zero)
        print("object",postRequest)
        self.statusType = postRequest.Status
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                print("userobject : ", userData_val)
                userDict = userData_val as! NSDictionary
            }
        }
       // self.tblDetail.reloadData()
    }

    @IBAction func clkBack(sender: UIButton)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK : tableview delegate and datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0
        {
            return 91
        }
        else if indexPath.row == 1
        {
            return 105
        }
        else if(indexPath.row == 2)
        {
            return 0
//            if(self.statusType != nil)
//            {
//                if(self.statusType == 1)
//                {
//                    return 61
//                }
//                else
//                {
//                    return 0
//                }
//            }
        }
        else
        {
            if(self.statusType != nil)
            {
                if(self.statusType == 3)
                {
                    return 115
                }
                else
                {
                    return 0
                }
            }
            
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell:HomeCell = tableView.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
            cell.lblTitle.text = postRequest.CourtName
            cell.lblSubtitle.text = postRequest.A_FirstName
            cell.lblLocation.text = postRequest.Address
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dt = formatter.dateFromString(postRequest.Date)
            formatter.dateFormat = "dd/MM/yyyy"
            print(formatter.stringFromDate(dt!))
            cell.lblDate.text = formatter.stringFromDate(dt!)
            
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 1 {
            
            let cell:HomeCell = tableView.dequeueReusableCellWithIdentifier("DetailCell") as! HomeCell
            cell.lblAddr.text = NSLocalizedString("Address", comment:"comm")
            cell.lblSerialNo.text = postRequest.Address
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 2
        {
            let cell:ButtonCell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as! ButtonCell
            
            cell.selectionStyle = .None
            return cell
        }
        else
        {
            let cell:ChatSubmit = tableView.dequeueReusableCellWithIdentifier("ChatSubmit") as! ChatSubmit
            cell.selectionStyle = .None
            return cell
        }
    }

    //MARK: View Detail clicked
    @IBAction func btnViewDetailClick(sender : UIButton)
    {
        let mentionDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MentionDetailViewController") as! MentionDetailViewController
        mentionDetailVC.principleObj = self.postRequest
        self.navigationController?.pushViewController(mentionDetailVC, animated: true)
    }
    
    //MARK: Chat clicked
    @IBAction func btnChatClick(sender : UIButton)
    {
        let messageView: MessageViewController = MessageViewController()
        
        messageView.receiverDict = NSMutableDictionary(dictionary: ["contactname":postRequest.A_FirstName,"toId": String(postRequest.MentionId)])
        messageView.userDict = NSMutableDictionary(dictionary: ["contactname":userDict["Token"] as! String, "token":userDict["Token"] as! String,"userid": String(userDict["userid"] as! Int)])
        self.navigationController?.pushViewController(messageView, animated: true)
    }
    
    //MARK: Outcome clicked
    @IBAction func btnOutcomeClick(sender : UIButton)
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PrincipleDetailViewController.didPopUpClose), name: "didPopupClose", object: nil)
        
        let popupView: PopupViewController = self.storyboard?.instantiateViewControllerWithIdentifier(PopupViewIdentifier) as! PopupViewController
        popupView.fromPrinciple = "yes"
        popupView.mentionID = String(postRequest.MentionId)
        self.navigationController?.presentpopupViewController(popupView, animationType: SLpopupViewAnimationType.Fade, completion: {
        })
    }
    
    //MARK: Popup obseve method
    func didPopUpClose() {
        self.navigationController?.dismissPopupViewController(SLpopupViewAnimationType.Fade)
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
