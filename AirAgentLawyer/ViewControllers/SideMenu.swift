//
//  SideMenu.swift
//  FoodLa
//
//  Created by Admin on 27/10/16.
//  Copyright © 2016 cearsinfotech. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate: class {
    func didFinishTask(sender: SideMenu, index : Int)
}

class SideMenuCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgIcon : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class SideMenu: UIViewController {

    weak var delegate:DetailViewControllerDelegate?
    var userType : Int!
    @IBOutlet var tblMenu : UITableView!
    
    var ArrUserMenu : NSMutableArray = NSMutableArray()
        //["Home", "My Schedule", "Chat", "My Profile", "Logout"]
    var ArrUserMenuImage : NSMutableArray = NSMutableArray()
        //["ic_drawer_home","ic_drawer_calendar","ic_drawer_chat","ic_drawer_profile","ic_drawer_logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblMenu.tableFooterView = UIView(frame: CGRect.zero)
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.userType = userData_val.valueForKey("UserType") as! Int
            }
        }
        if(self.userType == 1)
        {
//            ArrUserMenu  = ["Home", "My Schedule", "Chat", "My Profile", "Logout"]
//            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_chat","ic_drawer_profile","ic_drawer_logout"]
            
            ArrUserMenu  = ["Home", "My Schedule", "My Profile", "Logout"]
            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_profile","ic_drawer_logout"]
        }
        else if(self.userType == 2)
        {
            print("call api for court")
//            ArrUserMenu  = ["Home", "Post Project", "Chat", "My Profile", "Logout"]
//            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_chat","ic_drawer_profile","ic_drawer_logout"]
            
            ArrUserMenu  = ["Home", "Post Project", "My Profile", "Logout"]
            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_profile","ic_drawer_logout"]
            
        }
        else if(self.userType == 3)
        {
            print("call api for court")
//            ArrUserMenu  = ["Home","My Schedule", "Post Project", "Chat", "My Profile", "Logout"]
//            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_calendar","ic_drawer_chat","ic_drawer_profile","ic_drawer_logout"]
            
            ArrUserMenu  = ["Home","My Schedule", "Post Project", "My Profile", "Logout"]
            ArrUserMenuImage = ["ic_drawer_home","ic_drawer_calendar","ic_drawer_calendar","ic_drawer_profile","ic_drawer_logout"]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrUserMenu.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        let identifier = "MenuCell"
        var cell: SideMenuCell! = tableView.dequeueReusableCellWithIdentifier(identifier) as? SideMenuCell
        if cell == nil {
            tableView.registerNib(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SideMenuCell
        }
        
        cell.lblName.text = ArrUserMenu.objectAtIndex(indexPath.row) as? String
        cell.imgIcon.image = UIImage(named: ArrUserMenuImage.objectAtIndex(indexPath.row) as! String)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("You selected cell #\(indexPath.row)!")
        delegate?.didFinishTask(self, index: indexPath.row)
        
    }
}
