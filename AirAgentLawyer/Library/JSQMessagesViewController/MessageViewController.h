//
//  MessageViewController.h
//  TatraVector
//
//  Created by Apple on 11/06/16.
//  Copyright © 2016 cears. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "JSQMessagesViewController.h"

@interface MessageViewController : JSQMessagesViewController <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *receiverDict;
@property (nonatomic, strong) NSMutableDictionary *userDict;

@property (nonatomic, strong) NSDictionary *mentionObj;

@end
