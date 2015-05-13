//
//  JSONParserHelper.h
//  GOT-JUNK
//
//  Created by epau on 1/25/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParserHelper : NSObject

+ (NSDictionary*)dictFromJSONString:(NSString*)dataString forKeyword:(NSString*)keyword;
+ (NSArray*)arrayFromJSONString:(NSString*)dataString forKeyword:(NSString*)keyword;
+ (NSDictionary*)dictFromJSONString:(NSString*)dataString;

@end
