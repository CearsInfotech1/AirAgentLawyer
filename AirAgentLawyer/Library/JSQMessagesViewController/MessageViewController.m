//
//  MessageViewController.m
//  TatraVector
//
//  Created by Apple on 11/06/16.
//  Copyright © 2016 cears. All rights reserved.
//

#import "MessageViewController.h"
#import "JSQSystemSoundPlayer.h"
#import "JSQMessagesBubbleImage.h"
#import "JSQMessagesAvatarImage.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "JSQMessagesAvatarImageFactory.h"
#import "JSQPhotoMediaItem.h"

#import "PhotoMediaItem.h"

//#import "ADPopupView.h"
//#import "CommonClass.h"

//#import "FoodLa-Swift.h"
//#import "Reachability.h"
#import "AirAgentLawyer-Swift.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define		STATUS_LOADING						1
#define		STATUS_FAILED						2
#define		STATUS_SUCCEED						3

@interface MessageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *messages, *items;
    
    NSDateFormatter *df;
    
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    JSQMessagesAvatarImage *avatarImageBlank;
    UIImage *selectedImage;
    
    NSMutableDictionary *avatars, *started;
    BOOL IsFirst, IsConference, IsPopUpVisible;
    NSTimer *msgTimer;
}

//@property (nonatomic, strong) ADPopupView *visiblePopup;

@end

@implementation MessageViewController
@synthesize receiverDict, userDict;

- (id)init
{
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:@"didMessageReceived" object:nil];
    
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"chatViewReload" object:nil];

    avatars = [NSMutableDictionary dictionary];
    started = [NSMutableDictionary dictionary];
    
    items = [NSMutableArray array];
    messages = [NSMutableArray array];
    
    self.senderId = userDict[@"userid"];
    self.senderDisplayName = userDict[@"contactname"];
//    self.lblHeader.text = receiverDict[@"contactname"];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:0/255.0f green:174/255.0f blue:239/255.0f alpha:1.0]];
    
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profile_default.png"] diameter:30.0];
    
    self.automaticallyScrollsToMostRecentMessage = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view setUserInteractionEnabled:YES];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    msgTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateChat) userInfo:nil repeats:YES];
    
    IsFirst = YES;
    IsPopUpVisible = NO;
    
    self.menuView.hidden = YES;
    [self getMessageMethod];
}


-(void)refreshTable :(NSNotification *)notification {
    
    NSLog(@"dic : %@", notification.object);
    
    NSDictionary *dict1 = [NSDictionary dictionaryWithDictionary:(NSDictionary *)notification.object];
    NSMutableArray *data1 = [NSJSONSerialization JSONObjectWithData:[dict1[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    //[{"id":"238","fromId":"174","toId":"198","message":"Hello Get notification","attachment":"","created":"2016-11-24 11:36","itemid":"416","isViewed":"0"}]
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:data1[0]];
    
    if ([dict[@"message"] isEqualToString:@""] && ![dict[@"attachment"] isEqualToString:@""]) {
        
        [items addObject:@{@"fromId": dict[@"fromId"], @"name": dict[@"name"], @"status": @"", @"text": dict[@"message"], @"type": @"picture", @"image": dict[@"attachment"], @"profilePic" : dict[@"profilepic"]}];
        
        [messages addObject:[self createPictureMessage:dict]];
        
//        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:dict[@"attachment"]]];
//        UIImage *img = [UIImage imageWithData:data];
//        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:img];
//        JSQMessage *msg1 = [[JSQMessage alloc] initWithSenderId:dict[@"fromId"] senderDisplayName:dict[@"name"] date:[df dateFromString:dict[@"created"]] media:mediaItem];
//        [messages addObject:msg1];
//        
        self.automaticallyScrollsToMostRecentMessage = YES;
        [self finishReceivingMessage];
    }
    else {
        [items addObject:@{@"fromId": dict[@"fromId"], @"name": dict[@"name"], @"status": @"", @"text": dict[@"message"], @"type": @"text", @"image": dict[@"attachment"], @"profilePic" : dict[@"profilepic"]}];
        
        JSQMessage *msg1 = [[JSQMessage alloc] initWithSenderId:dict[@"fromId"] senderDisplayName:dict[@"name"] date:[df dateFromString:dict[@"created"]] text:dict[@"message"]];
        [messages addObject:msg1];
        
        self.automaticallyScrollsToMostRecentMessage = YES;
        [self finishReceivingMessage];

    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    [self finishReceivingMessage];
}


-(void) getMessageMethod {
    
    [[GlobalClass sharedInstance] startIndicator:NSLocalizedString(@"Loading...", @"comment")];
    
    NSString *BASE_URL = @"http://api.airagentapp.com.au/Api";
    NSString *apiurl = [NSString stringWithFormat:@"%@/Profile/GetchatHistory?userid=%@&Mentionid=%@", BASE_URL, userDict[@"userid"], receiverDict[@"toId"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:userDict[@"token"] forHTTPHeaderField:@"Token"];
    [request addValue:userDict[@"userid"] forHTTPHeaderField:@"UserId"];
    
    [[GlobalClass sharedInstance] get:request params:@"" completion:^(BOOL success, id  _Nullable object) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[GlobalClass sharedInstance] stopIndicator];
            
            if (success) {
                
                if (object != nil) {
                    NSLog(@"object : %@", object);
                    
                    if ([object[@"Data"] count] > 0) {
                        
                        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:object[@"Data"]];

                        for (NSDictionary *dict in arr) {

                            [items addObject:@{@"fromId": [dict[@"FromId"] stringValue], @"name": @"", @"status": @"", @"text": dict[@"Message"], @"type": @"text", @"image": @"", @"profilePic" : dict[@"UserProfilephoto"]}];
                            
                            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
//                            [df setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

//                            [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
//                            [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            
                            NSLog(@"date11 : %@", [df dateFromString:dict[@"ondate"]]);
                            
                            JSQMessage *msg1 = [[JSQMessage alloc] initWithSenderId:[dict[@"FromId"] stringValue] senderDisplayName:@"" date:[df dateFromString:dict[@"ondate"]] text:dict[@"Message"]];
                            [messages addObject:msg1];
                        }

                        self.automaticallyScrollsToMostRecentMessage = YES;
                        [self finishReceivingMessage];
                    }
                    else {
                        self.automaticallyScrollsToMostRecentMessage = YES;
                        [self finishReceivingMessage];
                    }
                }
            }
        });
    }];
    
}


-(void) updateChat {
    
    //NSLog(@"timer called");
    IsFirst = NO;
}

-(void) messageReceived: (NSNotification *) notification {
    
    NSDictionary *dict = (NSDictionary *) notification.object;
    
    //{"name":"admin123","email_id":"admin@admin.com","image":"http:\/\/appointment.cearsinfotech.com\/skin\/images\/profile_picture\/img969695294.jpg","id":"72","fromId":"1","toId":"7","message":"Hello","created":"2016-06-22 06:07","isViewed":"0","type":"chatmessage"}
    
    [items addObject:@{@"fromId": dict[@"fromId"], @"name": dict[@"name"], @"status": @"", @"text": dict[@"message"], @"type": @"text", @"image": dict[@"image"], @"profilePic" : dict[@"profilepic"]}];
    
    JSQMessage *msg1 = [[JSQMessage alloc] initWithSenderId:dict[@"fromId"] senderDisplayName:dict[@"name"] date:[df dateFromString:dict[@"created"]] text:dict[@"message"]];
    [messages addObject:msg1];
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    [self finishReceivingMessage];
}

-(void) backgroundTap:(UIGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
}

-(void)backBtnClicked1:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)optionBtnClicked:(id)sender {
    
    if ([self.menuView isHidden]) {
        self.menuView.hidden = NO;
    }
    else {
        self.menuView.hidden = YES;
    }
}

-(void)deleteBtnClicked:(id)sender {
    
}

- (BOOL)incoming:(NSDictionary *)item
{
    return (![self.senderId isEqualToString:item[@"fromId"]] == YES);
}

- (BOOL)outgoing:(NSDictionary *)item
{
    return ([self.senderId isEqualToString:item[@"fromId"]] == YES);
}

- (void)loadAvatar:(NSDictionary *)item
{
    if (started[item[@"fromId"]] == nil) started[item[@"fromId"]] = @YES; else return;
        [self downloadThumbnail:item];
        return;
}

- (void)downloadThumbnail:(NSDictionary *)item
{
    if (item[@"profilePic"] != nil) {
        __block NSData *data1;
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            data1 = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:item[@"profilePic"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([data1 length] > 0) {
                    
                    UIImage *image = [UIImage imageWithData:data1];
                    avatars[item[@"fromId"]] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
                    [self performSelector:@selector(delayedReload) withObject:nil afterDelay:0.1];
                }
                else {
                    [started removeObjectForKey:item[@"fromId"]];
                }
            });
        });
    }
}

- (void)delayedReload
{
    [self.collectionView reloadData];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date
{
    selectedImage = nil;
    [self messageSend:text Video:nil Picture:nil Audio:nil];
}

- (UIView *)contentView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    contentView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [btn1 setImage:[UIImage imageNamed:@"ic_chat_camera"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(ClkCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(51, 0, 50, 50)];
    [btn2 setImage:[UIImage imageNamed:@"ic_chat_gallery"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(ClkGallery) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:btn1];
    [contentView addSubview:btn2];
    
    return contentView;
}

-(void)ClkCamera
{
    IsPopUpVisible = NO;
//    [self.visiblePopup hide:YES];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Granted access to ");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    });
                } else {
                    NSLog(@"Not granted access to");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"App does not have access to your camera. You can enable access in Privacy Settings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                    });
                }
            }];
        }
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Camera is not available in your device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)ClkGallery
{
    IsPopUpVisible = NO;
//    [self.visiblePopup hide:YES];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"cancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    img = [self imageResize:img andResizeTo:CGSizeMake(270.0f, 270.0f)];
    selectedImage = img;
    
    [self messageSend:nil Video:nil Picture:img Audio:nil];
}

- (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) sendMessageMethod: (NSString *) msgTxt {
    
//    [[GlobalClass sharedInstance] startIndicator:NSLocalizedString(@"Loading...", @"comment")];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"Fromid"] = userDict[@"userid"];
    paramDic[@"Message"] = msgTxt;
    paramDic[@"MentionId"] = receiverDict[@"toId"];
    
    NSData *data1 = [NSJSONSerialization dataWithJSONObject:paramDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    
    NSString *BASE_URL = @"http://api.airagentapp.com.au/Api";
    
    NSString *apiurl = [NSString stringWithFormat:@"%@/Profile/AddChathistory", BASE_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiurl]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:userDict[@"token"] forHTTPHeaderField:@"Token"];
    [request addValue:userDict[@"userid"] forHTTPHeaderField:@"UserId"];
    
     [[GlobalClass sharedInstance] post:request params:jsonStr completion:^(BOOL success, id  _Nullable object) {
        
         [[GlobalClass sharedInstance] stopIndicator];
         
         if (success) {
            
             if (object != nil) {
                 NSLog(@"object : %@", object);
             }
         }
     }];
}

//GlobalClass.sharedInstance.startIndicator(NSLocalizedString("Loading...", comment: "comm"))
//
//let paramDic : NSMutableDictionary = NSMutableDictionary()
//paramDic.setValue(self.agentID, forKey: "UserId")
//paramDic.setValue(self.txtOldPass.text!, forKey: "OldPassword")
//paramDic.setValue(self.txtNewPass.text!, forKey: "NewPassword")
//let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramDic, options: NSJSONWritingOptions())
//let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
//print("json string",jsonString)
//
//
////API Calling
//
//let request = NSMutableURLRequest(URL: NSURL(string: BASE_URL+"Profile/ChangePassword")!)
//print("request",request)
//request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//request.addValue(self.Token, forHTTPHeaderField: "Token")
//request.addValue(self.agentID, forHTTPHeaderField: "UserId")
//
//GlobalClass.sharedInstance.post(request, params: jsonString) { (success, object) in
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//        print("obj",object)
//        GlobalClass.sharedInstance.stopIndicator()
//        if success
//        {
//            GlobalClass.sharedInstance.stopIndicator()
//            
//            if let object = object
//            {
//                print("response object",object)
//                if(object.valueForKey("IsSuccess") as! Bool == true)
//                {
//                    GlobalClass.sharedInstance.showAlert(APP_Title, msg: NSLocalizedString("Password Change Successfully", comment: "comm"))
//                    self.navigationController?.popViewControllerAnimated(true)
//                }
//            }
//        }
//    })
//}

//-(void) sendMessageMethod:(NSString *)msg {
//
//    if ([AppUtilities isConnectedToNetwork]) {
//
////        [AppUtilities showLoader];
//
//        NSMutableDictionary *dictParam = [[NSMutableDictionary alloc] init];
//        [dictParam setValue:[NSString stringWithFormat:@"%@",userDict[@"userid"]] forKey:@"fromId"];
//        [dictParam setValue:[NSString stringWithFormat:@"%@",receiverDict[@"toId"]] forKey:@"toId"];
//        [dictParam setValue:[NSString stringWithFormat:@"%@",msg] forKey:@"message"];
//        [dictParam setValue:[NSString stringWithFormat:@"%@",strItemID] forKey:@"itemid"];
//        [dictParam setValue:@"sendmessage" forKey:@"method"];
//        
////        NSString *param = [NSString stringWithFormat:@"method=sendmessage&fromId=%@&toId=%@&message=%@&itemid=%@", userDict[@"userid"], receiverDict[@"toId"], msg, strItemID];
//        
//        NSString *boundary = [self generateBoundaryString];
//        
//        NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://admin.oglae.com/api/foodlaapi1.php"]];
//        
////        NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://foodla.cearsinfotech.in/api/foodlaapi.php"]];
//                
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//        [request setHTTPShouldHandleCookies:NO];
//        [request setTimeoutInterval:30];
//        [request setHTTPMethod:@"POST"];
//        
//        // set Content-Type in HTTP header
//        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
//        NSData *body = [self createBodyWithBoundary:boundary parameters:dictParam];
//        
//        // setting the body of the post to the reqeust
//        [request setHTTPBody:body];
//        
//        // set the content-length
//        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        
//        // set URL
//        [request setURL:requestURL];
//        
//        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//            
////            dispatch_sync(dispatch_get_main_queue(), ^{
////                [AppUtilities hideLoader];
////            });
//            
//            if (connectionError) {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[NSString stringWithFormat:@"%@", [connectionError localizedDescription]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alert show];
//                return;
//            }
//            
//            NSError *error;
//            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
//            if ([self CheckError:error]) return;
//            
//            NSLog(@"Post Project Data : %@",jsonData);
//            if ([jsonData isKindOfClass:[NSDictionary class]])
//            {
//                if ([jsonData[@"success"] boolValue] == YES)
//                {
//                    
//                }
//                else
//                {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:[NSString stringWithFormat:@"%@", [jsonData valueForKey:@"message"]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                    [alert show];
//                }
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Problem occurred while processing your request." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alert show];
//                return;
//            }
//            
//            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"result = %@", result);
//        }];
//        
////        [AppUtilities post:param completion:^(BOOL success, id  _Nullable object) {
////            
//////            [AppUtilities hideLoader];
////            
////            if (success) {
////                
////                NSDictionary *responseDic = (NSDictionary *) object;
////                if ([responseDic count] > 0) {
////                    
////                    if ((responseDic[@"success"] != nil) && ([responseDic[@"success"] integerValue] == 1)) {
////                        
////                        NSLog(@"response : %@", responseDic);
////                    }
////                    else {
////                        [AppUtilities showAlert:@"Foodla" msg:responseDic[@"message"]];
////                    }
////                }
////                else {
////                    [AppUtilities showAlert:@"Foodla" msg:@"Problem occurred while processing your request."];
////                }
////                
////            }
////            else {
////                [AppUtilities showAlert:@"Foodla" msg:@"Problem occurred while processing your request."];
////            }
////        }];
//    }
//}

- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
{
    if(picture != nil)
    {
        NSDictionary *item = [self sendMessageWithImage:picture];
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        [items addObject:item];
        
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:picture];
        [messages addObject:[[JSQMessage alloc] initWithSenderId:userDict[@"userid"] senderDisplayName:userDict[@"contactname"] date:[NSDate date] media:mediaItem]];
        
    }
    else
    {
        NSDictionary *item = [self sendMessage:text];
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        [items addObject:item];
        [messages addObject:[[JSQMessage alloc] initWithSenderId:userDict[@"userid"] senderDisplayName:userDict[@"contactname"] date:[NSDate date] text:text]];
    }
    [self finishSendingMessage];
}

-(NSDictionary *)sendMessage:(NSString *) msgTxt {
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    item[@"fromId"] = userDict[@"userid"];
    item[@"name"] = userDict[@"contactname"];
    item[@"date"] = Date2String([NSDate date]);
    item[@"status"] = @"Delivered";
    
    item[@"text"] = msgTxt;
    item[@"type"] = @"text";
    
    [self sendMessageMethod:msgTxt];
    
    return item;
}

-(NSDictionary *)sendMessageWithImage:(UIImage *)picture {
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    
    item[@"fromId"] = userDict[@"userid"];
    item[@"name"] = userDict[@"contactname"];
    item[@"date"] = Date2String([NSDate date]);
    item[@"status"] = @"Delivered";
    
    item[@"text"] = @"";
    item[@"type"] = @"picture";
        
//    NSData *imageData = UIImageJPEGRepresentation(picture, 1.0);
//    NSString *encodedString = @"";
//    if (imageData.length > 0) {
//        
//        encodedString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//        encodedString = [encodedString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//    }
    
//    [self sendMessageMethod:@""];

    return item;
}

NSString* Date2String(NSDate *date)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self outgoing:items[indexPath.item]])
    {
        return bubbleImageOutgoing;
    }
    else {
        return bubbleImageIncoming;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = items[indexPath.item];
    
    if (avatars[item[@"fromId"]] == nil) {
        
        [self loadAvatar:item];
        return avatarImageBlank;
    }
    else {
        return avatars[item[@"fromId"]];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self incoming:items[indexPath.item]])
    {
        JSQMessage *message = messages[indexPath.item];
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return nil;
            }
        }
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = items[indexPath.item];
    if ([self outgoing:item])
    {
        return [[NSAttributedString alloc] initWithString:items[indexPath.item][@"status"]];
    }
    else
        return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *color = [self outgoing:items[indexPath.item]] ? [UIColor blackColor] : [UIColor whiteColor];
    
    UIColor *backcolor = [self outgoing:items[indexPath.item]] ? [UIColor whiteColor] : [UIColor colorWithRed:0/255.0f green:174/255.0f blue:239/255.0f alpha:1.0];
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = color;
    cell.textView.backgroundColor = backcolor;
    cell.textView.layer.cornerRadius = 5.0f;
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:color};
    
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self incoming:items[indexPath.item]])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *message = messages[indexPath.item];
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return 0;
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else
        return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self outgoing:items[indexPath.item]])
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
//    ActionPremium(self);
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *item = items[indexPath.item];
//    JSQMessage *message = messages[indexPath.item];
//    if ([item[@"type"] isEqualToString:@"picture"])
//    {
//        PhotoMediaItem *mediaItem = (PhotoMediaItem *)message.media;
//        
//        if (mediaItem.status == STATUS_SUCCEED)
//        {
//            NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
//            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
//            [self presentViewController:browser animated:YES completion:nil];
//        }
//    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *item = items[indexPath.item];
    
    if ([self incoming:item]) {
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
//        Profile *Obj = [storyBoard instantiateViewControllerWithIdentifier:@"Profile"];
//        Obj.isFromHome = @"1";
//        Obj.strUserID = item[@"fromId"];
//        [self.navigationController pushViewController:Obj animated:YES];
//        UINavigationController *rootViewController = (UINavigationController *) self.view.window.rootViewController;
//        [rootViewController pushViewController:Obj animated:YES];
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([msgTimer isValid]) {
        
        [msgTimer invalidate];
        msgTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - create Body with boundry
- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // add image data
//    for (int i = 0; i < arr_PassImages.count; i++) {
    
    if (selectedImage != nil) {
        NSData *ImageData = UIImageJPEGRepresentation(selectedImage, 1.0);
        
        NSString *filename  = [NSString stringWithFormat:@"MyImage_1.png"];
        NSData   *data      = ImageData;
        NSString *mimetype  = [self mimeTypeForData:ImageData];
        
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attachment\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:data];
        [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
//    }
    
    return httpBody;
}

#pragma mark - get mime type Method
- (NSString *)mimeTypeForData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
    return nil;
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (BOOL) CheckError:(NSError*)error
{
    if (error) {
        UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [Alert show];
        return YES;
    } else {
        return NO;
    }
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createPictureMessage:(NSDictionary *)item
{
    NSString *name = item[@"contactname"];
    NSString *userId = item[@"fromId"];
    NSDate *date = [df dateFromString:item[@"created"]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    PhotoMediaItem *mediaItem = [[PhotoMediaItem alloc] initWithImage:nil Width:[NSNumber numberWithFloat:300.0] Height:[NSNumber numberWithFloat:300.0]];
    mediaItem.appliesMediaViewMaskAsOutgoing = [self outgoing:item];
    
        //---------------------------------------------------------------------------------------------------------------------------------------------
    [self loadPictureMedia:item MediaItem:mediaItem];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}
//
////-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadPictureMedia:(NSDictionary *)item MediaItem:(PhotoMediaItem *)mediaItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    mediaItem.status = STATUS_LOADING;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:item[@"attachment"]]];
        UIImage *img = [UIImage imageWithData:data];
        mediaItem.image = img;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mediaItem.status = STATUS_SUCCEED;
//            self.automaticallyScrollsToMostRecentMessage = YES;
            [self finishReceivingMessage];
        });
    });
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    [AFDownload start:item[@"picture"] md5:item[@"picture_md5hash"] complete:^(NSString *path, NSError *error, BOOL network)
//     {
    
//    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:dict[@"attachment"]]];
//    UIImage *img = [UIImage imageWithData:data];
//    mediaItem.image = img;
    
//         if (error == nil)
//         {
//             mediaItem.status = STATUS_SUCCEED;
////             if (network) DecryptFile(groupId, path);
//             mediaItem.image = [[UIImage alloc] initWithContentsOfFile:path];
//         }
//         else mediaItem.status = STATUS_FAILED;
//         if (network) {
//             self.automaticallyScrollsToMostRecentMessage = YES;
//            [self finishReceivingMessage];
//         }
//     }];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
NSDate* String2Date(NSString *dateStr)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter dateFromString:dateStr];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
