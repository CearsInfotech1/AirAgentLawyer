//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "NSBundle+JSQMessages.h"
//#import "GlobalClass.h"


@implementation JSQMessagesToolbarButtonFactory

+ (UIButton *)defaultAccessoryButtonItem
{
    UIImage *accessoryImage = [UIImage imageNamed:@"ic_chat_attachment"];
                               //jsq_defaultAccessoryImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];

    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:normalImage forState:UIControlStateNormal];
    [accessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];

    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = [UIColor lightGrayColor];

    return accessoryButton;
}

+ (UIButton *)defaultSendButtonItem
{
//    NSString *sendTitle = [NSBundle jsq_localizedStringForKey:@"  SEND  "];

    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setImage:[UIImage imageNamed:@"ic_chat_msg_send"] forState:UIControlStateNormal];
//    [sendButton setTitleColor:[UIColor jsq_messageBubbleBlueColor] forState:UIControlStateNormal];
//    [sendButton setTitleColor:[[UIColor jsq_messageBubbleBlueColor] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    //jinal
//    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
//    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

//    sendButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16.0f];
//    //[UIFont boldSystemFontOfSize:17.0f];
//    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    //jinal
//    sendButton.layer.cornerRadius = 3.0f;
    sendButton.backgroundColor = [UIColor whiteColor];
                                  //colorWithRed:124/255.0 green:77/255.0 blue:255/255.0 alpha:1.0];
//    sendButton.tintColor = [UIColor jsq_messageBubbleBlueColor];
//
//    CGFloat maxHeight = 32.0f;
//
//    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
//                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
//                                                   context:nil];
//
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  40.0f,
                                  32.0f);

    return sendButton;
}

@end
