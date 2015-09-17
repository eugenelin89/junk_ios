//
//  HTTPClientSingleton.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "HTTPClientSingleton.h"
#include <CommonCrypto/CommonDigest.h>

static NSString * const API_PUBLIC_KEY = @"6773328730";
static NSString * const API_PRIVATE_KEY = @"2062497429";
static NSString * const kBASEURL = @"https://api.1800gotjunk.com/"; // Don't forget the slash at the end!  kBASEURL gets used in generating of MD5 checksum and without the slash authentication will fail.
//static NSString * const kBASEURL = @"https://apidev1.1800gotjunk.com/";  // TEST API

@implementation HTTPClientSingleton

+ (HTTPClientSingleton *)sharedInstance {
  static HTTPClientSingleton *_sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedInstance = [[HTTPClientSingleton alloc] initWithBaseURL:[NSURL URLWithString:kBASEURL]];
  });
  return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  return self;
}

-(void)setHeaderUsername:(NSString*)un andPassword:(NSString*)pw
{
    [self setAuthorizationHeaderWithUsername:un password:pw];
    self.parameterEncoding = AFPropertyListParameterEncoding;
}

- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setAuthHeader:path];
    [super getPath:path parameters:parameters success:success failure:failure];
}

- (void)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setAuthHeader:path];
    [super putPath:path parameters:parameters success:success failure:failure];
}

- (void)postPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setAuthHeader:path];
    [super postPath:path parameters:parameters success:success failure:failure];
}

- (void)deletePath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self setAuthHeader:path];
    [super deletePath:path parameters:parameters success:success failure:failure];
}

- (void)setAuthHeader:(NSString*)path
{
    NSString *token = [[NSString alloc] init];
    NSCalendar * preferredCalendar = [NSCalendar currentCalendar];
    // current date in UTC
    NSDate * date = [NSDate date];
    // jan 1, 1970
    NSDate * pointInTime = [[NSDate alloc] init];
    NSDateComponents * pointInTimeComponents = [[NSDateComponents alloc] init];
    [pointInTimeComponents setYear:1970];
    [pointInTimeComponents setMonth:1];
    [pointInTimeComponents setDay:1];
    pointInTime = [preferredCalendar dateFromComponents:pointInTimeComponents];
    NSDateComponents * resultComponents = [preferredCalendar components:NSCalendarUnitSecond fromDate:pointInTime toDate:date options:0];
    int seconds = resultComponents.second;
    NSString * md5Checksum = [self getMD5Checksum:path];
    token = [NSString stringWithFormat:@"%@;;%@;%@", API_PUBLIC_KEY, [NSString stringWithFormat:@"%d",seconds], md5Checksum];
    
    /*
     The authentication screen is comprised of the following components, separated by semicolons.
     {public API key};
     {empty string};
     {diff in seconds between jan 1, 1970 and current utctime};
     {md5 checksum consisting of full URL of the call and the private API Key; this whole thing is the auth_signature}
     */
    [self setDefaultHeader:@"Authentication" value:token];
}

- (NSString *)getMD5Checksum:(NSString *)path
{
    NSString *privateApiKey = API_PRIVATE_KEY;
    NSString *fullUrl = [kBASEURL stringByAppendingString:path];
    NSString *inputString = [privateApiKey stringByAppendingString:fullUrl];
    const char *cStr = [inputString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [[NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ] uppercaseString];
}

-(void)clearUsernameAndPassword
{
  [self clearAuthorizationHeader];
}

@end