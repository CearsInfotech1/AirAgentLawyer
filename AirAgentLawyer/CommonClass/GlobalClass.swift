//
//  GlobalClass.swift
//  DirectBazaar
//
//  Created by Apple on 04/08/16.
//  Copyright © 2016 cears. All rights reserved.
//

import UIKit

var UserDict: NSMutableDictionary = NSMutableDictionary()
var UserToken: String = ""
var NotificationTimeStamp = ""
var notificationCount = 0

protocol GlobalDelegate {
    func didMethodFinish(status:String)
}

class HomeCell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var lblAddr: UILabel!
    @IBOutlet var lblSerialNo: UILabel!
}

class ButtonCell: UITableViewCell {
    
    @IBOutlet var btnAccept: UIButton!
    @IBOutlet var btnReject: UIButton!
}
class ChatSubmit : UITableViewCell
{
    @IBOutlet var btnChat: UIButton!
    @IBOutlet var btnViewDetail: UIButton!
    @IBOutlet var btnSubmitOutCome : UIButton!
    
}

class ChatListCell : UITableViewCell
{
    @IBOutlet var imgCell: UIImageView!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblMsg : UILabel!
    @IBOutlet var lblTitle : UILabel!
}

class GlobalClass: NSObject {
    
    var delegate :GlobalDelegate?
    
    class var sharedInstance :GlobalClass {
        struct Singleton {
            static let instance = GlobalClass()
        }
        
        return Singleton.instance
    }
    
    func testmethod()
    {
        print("testing singleton")
    }
    
    func showAlert(title : NSString, msg : NSString) {
        let alert = UIAlertView(title: title as String, message: msg as String, delegate: nil, cancelButtonTitle: "OK")
        dispatch_async(dispatch_get_main_queue()) {
            alert.show()
        }
    }
    
    func bottomSelectedBorderColor(textField :AnyObject) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 2, textField.frame.width, 2.0)
        bottomLine.backgroundColor = Theme_Color.CGColor
        textField.layer.addSublayer(bottomLine)
    }
    func bottomSelectedBorderColorSignup(textField :AnyObject) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 2, textField.frame.width, 2.0)
        bottomLine.backgroundColor = Selected_Color.CGColor
        textField.layer.addSublayer(bottomLine)
    }
    
    func bottomBorderColorSignup(textField :AnyObject) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 2, textField.frame.width, 2.0)
        bottomLine.backgroundColor = UIColor.whiteColor().CGColor
        textField.layer.addSublayer(bottomLine)
    }
    
    func bottomBorderColor(textField :AnyObject) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, textField.frame.height - 2, textField.frame.width, 2.0)
        bottomLine.backgroundColor = LightGray_Color.CGColor
        textField.layer.addSublayer(bottomLine)
    }
    
    func setPlaceholder (textFiled : UITextField , str : String) {
        textFiled.attributedPlaceholder = NSAttributedString(string:str, attributes:[NSForegroundColorAttributeName: LightGray_Color])
    }
    
    func setSelectedPlaceholder (textFiled : UITextField , str : String) {
        textFiled.attributedPlaceholder = NSAttributedString(string:str, attributes:[NSForegroundColorAttributeName: Theme_Color.CGColor])
    }
    
    func imageResize(img: UIImage, newSize: CGSize) -> UIImage {
        
        let scale: CGFloat = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        img.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imageResizeWithAspect(sourceImage: UIImage, i_width: CGFloat) -> UIImage {
        
        let oldWidth: CGFloat = sourceImage.size.width
        let scaleFactor: CGFloat = i_width / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        
        let scale: CGFloat = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), false, scale)
        sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL!.path!
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    class func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(testStr)
        return result
    }

//    +(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
//    {
//    float oldWidth = sourceImage.size.width;
//    float scaleFactor = i_width / oldWidth;
//    
//    float newHeight = sourceImage.size.height * scaleFactor;
//    float newWidth = oldWidth * scaleFactor;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//    }
    
    func startIndicator(msg : String)
    {
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 100
        config.backgroundColor = UIColor.whiteColor()
        config.spinnerColor = Theme_Color
        config.titleTextColor = Theme_Color
        config.titleTextFont = UIFont(name: "American Typewriter", size: 15.0)!
        config.spinnerLineWidth = 1.0
        config.foregroundColor = UIColor.blackColor()
        config.foregroundAlpha = 0.5
        
        SwiftLoader.setConfig(config)
        
        SwiftLoader.show(true)
        SwiftLoader.show(msg, animated: true)
    }

    
    func stopIndicator()
    {
        SwiftLoader.hide()
    }
    
    /*=======================================================
     Function Name: dataTask
     Function Param : - URL,Strig,String,Block
     Function Return Type : -
     Function purpose :- Global Class For API Calling.
     ========================================================*/
    
    func dataTask(request: NSMutableURLRequest, method: String,params:NSString, completion: (success: Bool, object: AnyObject?) -> ()) {
        
        request.HTTPMethod = method
        request.HTTPBody = params.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data {
                let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                if let response = response as? NSHTTPURLResponse where 200...299 ~= response.statusCode {
                    completion(success: true, object: json)
                } else {
                    completion(success: false, object: json)
                }
            }
            }.resume()
    }
    
    func post(request: NSMutableURLRequest,params:NSString, completion: (success: Bool, object: AnyObject?) -> ()) {
        dataTask(request, method: "POST", params: params, completion: completion)
        
    }
    func put(request: NSMutableURLRequest,params:NSString, completion: (success: Bool, object: AnyObject?) -> ()) {
        dataTask(request, method: "PUT", params: params, completion: completion)
        
    }
    func get(request: NSMutableURLRequest,params:NSString, completion: (success: Bool, object: AnyObject?) -> ()) {
        dataTask(request, method: "GET", params: params, completion: completion)
        
    }


  /*  func isNetworkRechable() -> Bool {
        var networkReachability: Reachability = Reachability.reachabilityForInternetConnection()
        var networkStatus: NetworkStatus = networkReachability.currentReachabilityStatus()
        if networkStatus == NotReachable {
            GlobalClass.hideLoading()
            var alert: UIAlertView = UIAlertView(title: "Message", message: "Unable to connect to the Internet", delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert.show()
            return false
        }
        else {
            return true
        }
    }
    func showLoadingWithView(view1: UIView, withLabel lblString: String) {
        DejalBezelActivityView.activityViewForView(view1, withLabel: lblString)
    }
    
    func hideLoading() {
        DejalBezelActivityView.removeViewAnimated(true)
    }*/
    
}

//TextField Inset//

class MyTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
