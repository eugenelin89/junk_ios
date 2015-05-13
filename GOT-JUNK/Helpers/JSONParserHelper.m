//
//  JSONParserHelper.m
//  GOT-JUNK
//
//  Created by epau on 1/25/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "JSONParserHelper.h"
#import "SBJson.h"

@implementation JSONParserHelper

+ (NSDictionary*)dictFromJSONString:(NSString*)dataString forKeyword:(NSString*)keyword
{
  SBJsonParser *jsonparser = [SBJsonParser new];
  NSError *error;
  NSDictionary *dict = [jsonparser objectWithString:dataString error:&error];
  if (!dict)
  {
    NSLog(@"ERROR PARSING JSON RESPONSE: %@", error);
    return nil;
  }
  else
  {
    NSDictionary *dictForKeyword = [dict objectForKey:keyword];
    return dictForKeyword;
  }
}

+ (NSArray*)arrayFromJSONString:(NSString*)dataString forKeyword:(NSString*)keyword
{
  SBJsonParser *jsonparser = [SBJsonParser new];
  NSError *error;
  NSDictionary *dict = [jsonparser objectWithString:dataString error:&error];
  if (!dict)
  {
    NSLog(@"ERROR PARSING JSON RESPONSE: %@", error);
    return nil;
  }
  else
  {
   NSArray *objs = [dict objectForKey:keyword];
    return objs;
  }
}

+ (NSDictionary*)dictFromJSONString:(NSString*)dataString
{
    SBJsonParser *jsonparser = [SBJsonParser new];
    NSError *error;
    NSDictionary *dict = [jsonparser objectWithString:dataString error:&error];
    return dict;
}

@end
