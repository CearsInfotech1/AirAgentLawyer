//
//  BaseViewController.swift
//  FoodLa
//
//  Created by Admin on 27/10/16.
//  Copyright © 2016 cearsinfotech. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var menuView : UIView!
    
    var view1: SideMenu!
    
    var isMenuView : Bool = false
    var userTypeVal : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user_Data = NSUserDefaults.standardUserDefaults().objectForKey("USER_OBJECT") as? NSData
        if let userData = user_Data {
            let userObj = NSKeyedUnarchiver.unarchiveObjectWithData(userData)
            
            if let userData_val = userObj {
                
                self.userTypeVal = userData_val.valueForKey("UserType") as! Int
            }
        }
        
        self.view1 = SideMenu(nibName: "SideMenu", bundle: nil)
        self.view1.view.backgroundColor = UIColor.clearColor()
        view1.delegate = self
        view1.view.frame = CGRectMake(-self.view.frame.width, 64, self.view.frame.width, self.view.frame.height - 64)
        
//        view1.view.layer.shadowColor = UIColor.blackColor().CGColor
//        view1.view.layer.shadowOpacity = 0.5
//        view1.view.layer.shadowRadius = 10
//        
//        let path = UIBezierPath(rect : CGRectMake(view1.view.frame.width - 80.0, 0, 20, CGRectGetHeight(view1.view.frame)))
//        view1.view.layer.shadowPath = path.CGPath
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(BaseViewController.respondToSwipeGesture1(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view1.view.addGestureRecognizer(swipeLeft)
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(BaseViewController.respondToSwipeGesture1(_:)))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        self.view1.view.addGestureRecognizer(swipeRight)
    }
    
    func respondToSwipeGesture1(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped Right")
                self.SwipeShowView(nil)
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                print("Swiped left")
                self.SwipeHideView(nil)
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }

    
    @IBAction func loadView(sender : AnyObject!)
    {        
        if isMenuView {
            UIView.animateWithDuration(0.3, animations: {
                
                self.isMenuView = false
                self.view1.view.frame = CGRectMake(-self.view.frame.width, 64, self.view.frame.width, self.view.frame.height - 64 )
            }) { (finished) in
                
                self.view1.view.removeFromSuperview()
            }
        }
        else
        {
            UIView.animateWithDuration(0.3, animations: {
                
                self.isMenuView = true
                self.view1.view.frame = CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 64 )
                self.view.addSubview(self.view1.view)
            }) { (finished) in
                
            }
        }
    }
    
    @IBAction func SwipeHideView(sender : AnyObject!)
    {
        if isMenuView {
            UIView.animateWithDuration(0.3, animations: {
                
                self.isMenuView = false
                self.view1.view.frame = CGRectMake(-self.view.frame.width, 64, self.view.frame.width, self.view.frame.height - 64 )
            }) { (finished) in
                
                self.view1.view.removeFromSuperview()
            }
        }
    }
    
    @IBAction func SwipeShowView(sender : AnyObject!)
    {
        if !isMenuView {
            UIView.animateWithDuration(0.3, animations: {
                
                self.isMenuView = true
                self.view1.view.frame = CGRectMake(0, 64, self.view.frame.width, self.view.frame.height - 64 )
                self.view.addSubview(self.view1.view)
            }) { (finished) in
                
            }
        }
    }
}

extension BaseViewController: DetailViewControllerDelegate {
    func didFinishTask(sender: SideMenu, index : Int) {
        if isMenuView {
            UIView.animateWithDuration(0.3, animations: {
                self.isMenuView = false
                self.view1.view.frame = CGRectMake(-self.view.frame.width, 64, self.view.frame.width, self.view.frame.height - 64)
            }) { (finished) in
                
                self.view1.view.removeFromSuperview()
                
                if index == 0 {
                    if(self.userTypeVal == 1 || self.userTypeVal == 2)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController") as! HomeViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                    else if(self.userTypeVal == 3)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("AgentPrincipleViewController") as! AgentPrincipleViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                }
                else if index == 1
                {
                    if(self.userTypeVal == 1 || self.userTypeVal == 3)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(MyScheduleIdentifier) as! MyScheduleViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                    else if(self.userTypeVal == 2)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectViewController") as! PostProjectViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                   
                }
                else if index == 2
                {
                    if(self.userTypeVal == 3)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("PostProjectViewController") as! PostProjectViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                    else
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(ProfileViewIdentifier) as! ProfileViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
//                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(ChatListViewIdentifier) as! ChatListViewController
//                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                }
//                else if index == 3 {
//                    let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("MyOrderViewController") as! MyOrderViewController
//                    self.navigationController?.pushViewController(Obj, animated: false)
//                }*/
//                else if index == 3
//                {
//                    if(self.userTypeVal == 3)
//                    {
//                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(ChatListViewIdentifier) as! ChatListViewController
//                        self.navigationController?.pushViewController(Obj, animated: false)
//                    }
//                    else
//                    {
//                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(ProfileViewIdentifier) as! ProfileViewController
//                        self.navigationController?.pushViewController(Obj, animated: false)
//                    }
//                }
                else if index == 3
                { // Logout
                    if(self.userTypeVal == 3)
                    {
                        let Obj = self.storyboard?.instantiateViewControllerWithIdentifier(ProfileViewIdentifier) as! ProfileViewController
                        self.navigationController?.pushViewController(Obj, animated: false)
                    }
                    else
                    {
                        let alert = UIAlertView(title: "Are you sure you want to Logout?", message: "", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
                        dispatch_async(dispatch_get_main_queue()) {
                            alert.tag == 102
                            alert.show()
                        }
                    }
                }
                else if index == 4
                {
                    if(self.userTypeVal == 3)
                    {
                        let alert = UIAlertView(title: "Are you sure you want to Logout?", message: "", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
                        dispatch_async(dispatch_get_main_queue()) {
                            alert.tag == 102
                            alert.show()
                        }

                    }
                }
            }
            
        }
    }
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 1:
//            self.logOutMethod()
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.removeObjectForKey("USER_OBJECT")
            let Obj = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.navigationController?.setViewControllers([Obj], animated: false)
            self.navigationController?.popViewControllerAnimated(false)
            
            break;
        case 0:
            break;
        default:
            NSLog("Default");
            break;
        }
    }
}
