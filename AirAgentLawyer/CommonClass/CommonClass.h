//
//  CommonClass.h
//  AirAgentLawyer
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonClass : NSObject

+(CommonClass *)sharedInstance;
-(NSMutableArray *) arrayByReplacingNullsWithString:(NSMutableArray *) nullArray;
- (NSDictionary *) dictionaryByReplacingNullsWithStrings:(NSDictionary *)nullDic;

@end
