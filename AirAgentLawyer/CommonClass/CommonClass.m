//
//  CommonClass.m
//  AirAgentLawyer
//
//  Created by Apple on 21/12/16.
//  Copyright © 2016 cears. All rights reserved.
//

#import "CommonClass.h"

@implementation CommonClass

static CommonClass * _sharedInstance = nil;

+(CommonClass *)sharedInstance
{
    @synchronized([CommonClass class])
    {
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
        
        return _sharedInstance;
    }
    
    return nil;
}

- (id)init {
    if (self = [super init]) {
    
    }
    
    return self;
}


-(NSMutableArray *) arrayByReplacingNullsWithString:(NSMutableArray *) nullArray {
    
    for (int i = 0; i < [nullArray count]; i++) {
        
        [nullArray replaceObjectAtIndex:i withObject:[self dictionaryByReplacingNullsWithStrings:nullArray[i]]];
    }
    
    return nullArray;
}


- (NSDictionary *) dictionaryByReplacingNullsWithStrings:(NSDictionary *)nullDict {
    
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary: nullDict];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    
    for (NSString *key in nullDict) {
        const id object = [nullDict objectForKey: key];
        if (object == nul) {
            [replaced setObject: blank forKey: key];
        }
        else if ([object isKindOfClass: [NSDictionary class]]) {
            [replaced setObject: [self dictionaryByReplacingNullsWithStrings:object] forKey: key];
        }
    }
    return [NSDictionary dictionaryWithDictionary: replaced];
}

@end
