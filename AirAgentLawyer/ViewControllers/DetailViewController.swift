//
//  DetailViewController.swift
//  AirAgentLawyer
//
//  Created by Apple on 24/11/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblDetail: UITableView!
    var obj : MentionRequest = MentionRequest()
    var statusType : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblDetail.delegate = self
        tblDetail.dataSource = self
        tblDetail.tableFooterView = UIView(frame: CGRect.zero)
        print("object",obj)
        self.statusType = obj.Status
    }
    
    @IBAction func clkBack(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    //MARK : tableview delegate and datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 91
        }
        else if indexPath.row == 1 {
            return 105
        }
        else if(indexPath.row == 2)
        {
            if(self.statusType == "1")
            {
                return 61
            }
            else
            {
                return 0
            }
        }
        return 115
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell:HomeCell = tableView.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
            cell.lblTitle.text = obj.CourtName
            cell.lblSubtitle.text = obj.ClientName
            cell.lblLocation.text = obj.CourtAddress
            let formatter : NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dt = formatter.dateFromString(obj.MentionDate)
            formatter.dateFormat = "dd/MM/yyyy"
            print(formatter.stringFromDate(dt!))
            cell.lblDate.text = formatter.stringFromDate(dt!)
          
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 1 {
            
            let cell:HomeCell = tableView.dequeueReusableCellWithIdentifier("DetailCell") as! HomeCell
            cell.lblAddr.text = obj.CourtAddress
            cell.lblSerialNo.text = obj.CourtCity
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
        mentionDetailVC.objOfMention = self.obj
        self.navigationController?.pushViewController(mentionDetailVC, animated: true)
    }
    
    //MARK: Chat clicked
    @IBAction func btnChatClick(sender : UIButton)
    {
        let mentionDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MentionDetailViewController") as! MentionDetailViewController
        mentionDetailVC.objOfMention = self.obj
        self.navigationController?.pushViewController(mentionDetailVC, animated: true)
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
