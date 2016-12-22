//
//  Constant.swift
//  Laundry
//
//  Created by cears infotech on 7/18/16.
//  Copyright © 2016 cears infotech. All rights reserved.
//

import UIKit


let Theme_Color = UIColor(red: 44/255.0, green: 62/255.0, blue: 80/255.0, alpha: 1.0)
//239,80,80
//0,174,239
let Selected_Color = UIColor(red: 44/255, green: 183/255, blue: 243/255, alpha: 1.0)

let LightGray_Color = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1.0)
let DarkGray_Color = UIColor(red: 98/255.0, green: 99/255.0, blue: 99/255.0, alpha: 1.0)

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height

extension String {
    public static func localize(key: String) -> String {
        return NSLocalizedString(key, comment: key)
    }
}

class Constant: NSObject {

}

//URL Constant
let BASE_URL = "http://api.airagentapp.com.au/Api/"


// App Constant
let APP_Title = "AirAgentLawyer"
let LoginViewIdentifier = "LoginViewController"
let RegisterViewIdentifier = "SignupViewController"
let ProfileViewIdentifier = "ProfileViewController"
let HomeViewIdentifier = "HomeViewController"
let DetailViewIdentifier = "DetailViewController"
let ScheduleViewIdentifier = "AddScheduleViewController"
let MyScheduleIdentifier = "MyScheduleViewController"
let PopupViewIdentifier = "PopupViewController"
let ChatListViewIdentifier = "ChatListViewController"

//
//
//// API Constant
//let Amazon_ProfileURL = "https://s3.amazonaws.com/soopin/ProfileImage/"
//let Amazon_PostURL = "https://s3.amazonaws.com/soopin/PostImage/"
//let Amazon_PostVideoURL = "https://s3.amazonaws.com/soopin/PostVideo/"



