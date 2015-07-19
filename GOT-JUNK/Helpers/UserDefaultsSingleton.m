//
//  UserDefaultsSingleton.m
//  GOT-JUNK
//
//  Created by epau on 1/30/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "UserDefaultsSingleton.h"
#import "DateHelper.h"
#import "NSString+MD5.h"
#import <UIKit/UIKit.h>

@implementation UserDefaultsSingleton

+ (UserDefaultsSingleton *)sharedInstance {
    static UserDefaultsSingleton *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[UserDefaultsSingleton alloc] initWithUserDefaults];
    });
    
    return _sharedInstance;
}

#pragma mark - Initialization

- (id)initWithUserDefaults
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    

    return self;
}

- (BOOL)isFirstTimeInstall
{
    // Carefull testing this on the simulator:
    //    http://stackoverflow.com/questions/24985825/nsuserdefaults-not-cleared-after-app-uninstall-on-simulator
    //  You need to reset all content on the simulator
    //
    NSString *obj = [_userDefaults objectForKey:@"firstTimeInstall"];
    return obj == nil;
}

- (void)setInstalled
{
    [_userDefaults setObject:@"1" forKey:@"firstTimeInstall"];
    [_userDefaults synchronize];
}

#pragma mark - Clear Data

- (void)clearAllData
{
    [self setUserSessionID:@""];
}

#pragma mark - Retrieval
- (NSString*)getServerDate
{
    //return @"ea7c7bcc-84a5-4bf7-85fe-ee863f12db05";
    
    NSString *obj = [_userDefaults objectForKey:@"serverDate"];
    if (obj)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getUserSessionPermissionsPath
{
    NSString *sessionID = [self getUserSessionID];
    NSNumber *franchiseID = [self getUserDefaultFranchiseID];
    return [NSString stringWithFormat:@"sessionID=%@&franchiseID=%d", sessionID, [franchiseID integerValue]];
}

- (NSString*)getUserSessionID
{
    NSString *obj = [_userDefaults objectForKey:@"sessionID"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}
-(NSString*)getUserPermissions
{
    NSString *obj = [_userDefaults objectForKey:@"userPermissions"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
    
}
- (NSNumber*)getUserDefaultRouteID
{
    NSNumber *obj = [_userDefaults objectForKey:@"defaultRouteID"];
    if (obj)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}
- (NSString *)getUserDefaultFranchiseName;
{
    NSString *obj = [_userDefaults objectForKey:@"defaultFranchiseName"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (BOOL)setMapSwitch:(BOOL)isOn
{
    if (isOn == YES)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
        {
            [_userDefaults setBool:YES forKey:@"useGoogleMaps"];
        }
        else
        {
            return NO;
        }
    }
    else
    {
        [_userDefaults setBool:NO forKey:@"useGoogleMaps"];
    }
    
    [_userDefaults synchronize];
    return YES;
}


- (BOOL)getUseGoogleMaps
{
    return [_userDefaults boolForKey:@"useGoogleMaps"];
}

- (void)setColorPreference:(BOOL)isOn
{
    [_userDefaults setBool:isOn forKey:@"useJunknetColors"];
    [_userDefaults synchronize];
}

- (BOOL)getUserColorPref
{
    return [_userDefaults boolForKey:@"useJunknetColors"];
}

- (void)offlineModeEnabled
{
    [_userDefaults setBool:YES forKey:@"offlineModeEnabled"];
}

- (void)offlineModeDisabled
{
    [_userDefaults setBool:NO forKey:@"offlineModeEnabled"];
}
-(void)storeOfflineKey:(NSString * )myKey
{
    [_userDefaults setObject:myKey forKey:@"storedHashKey"];
    [_userDefaults synchronize];

}

- (BOOL)isOfflineAuthorized
{
    //special algorithm for offline mode as details in secretoffline access key google document
    NSString *myString =  [DateHelper nowString];  //todays date
    int myDateNumber2 = [myString integerValue];  //converted into a number
    int myDateNumber = [myString integerValue]; //converted into a number
    myDateNumber = myDateNumber % 7 + 2;  //mode 7 + 2
    int myDateNumberFact = [self factorialX: myDateNumber];  //factorial
    int myFinal = myDateNumberFact + myDateNumber2;  //add together
    NSString * myHashString = [NSString stringWithFormat:@"%d", myFinal];  //convert into a string
    NSString * myHashStringHashed = [myHashString MD5String];  //hash it with MD5String
    myHashStringHashed =  [myHashStringHashed substringToIndex:10];  //trim to 10 characters
    NSString *storedKey = [_userDefaults objectForKey:@"storedHashKey"];
    if ([[storedKey uppercaseString] isEqualToString:myHashStringHashed])
        return YES;
    else
        return NO;
}
-(double) factorialX: (int) value {
    double tempResult = 1;
    for (int i=2; i<=value; i++) {
        tempResult *= i;
    }
    return tempResult;
}

- (NSNumber*)getUserDefaultFranchiseID
{
    NSNumber *obj = [_userDefaults objectForKey:@"defaultFranchiseID"];
    if (obj)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSNumber*)getUserID
{
    NSNumber *obj = [_userDefaults objectForKey:@"userID"];
    if (obj)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getUserLogin
{
    NSString *obj = [_userDefaults objectForKey:@"login"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getUserFullName
{
    NSString *obj = [_userDefaults objectForKey:@"fullName"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getUserDefaultRouteName
{
    NSString *obj = [_userDefaults objectForKey:@"defaultRouteName"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}
- (NSString*)getUserDefaultTaxType
{
    NSString *obj = [_userDefaults objectForKey:@"defaultTaxType"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}
- (NSArray*)getUserDefaultRejectedJobs
{
    NSArray *obj = [_userDefaults objectForKey:@"rejectedJobs"];
    if (obj && [obj count] > 0)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSMutableArray *)getUserAcknowledgedDispatches
{
    NSMutableArray *obj = [_userDefaults objectForKey:@"acknowledgedDispatches"];
    if (obj && obj.count > 0)
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (BOOL)didUserAcknowledgeDispatch:(NSNumber*)dispatchID
{
    NSMutableArray *acknowledgedDispatches = [_userDefaults objectForKey:@"acknowledgedDispatches"];
    
    return (acknowledgedDispatches && [acknowledgedDispatches containsObject:dispatchID]);
}

- (BOOL)didUserRejectJobWithID:(NSNumber*)jobID
{
    if([self getUserDefaultRejectedJobs])
    {
        for (NSNumber *n in [self getUserDefaultRejectedJobs])
        {
            if ([jobID integerValue] == [n integerValue])
            {
                return YES;
                break;
            }
        }
    }
    return NO;
}

- (NSDictionary*)getJobsUserHasSeenAndNotAccepted
{
    NSDictionary *dict = [_userDefaults dictionaryForKey:@"jobsSeenAndNotAccepted"];
    if (dict && [dict count] > 0)
    {
        return dict;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getFeedbackEmail
{
    NSString *obj = [_userDefaults objectForKey:@"feedbackEmail"];
    if (obj && ![obj isEqualToString:@""])
    {
        return obj;
    }
    else
    {
        return nil;
    }
}

- (NSDate *)getDateLastCheckedUpdate
{
    return [_userDefaults objectForKey:@"lastCheckDate"];
    
}

- (void)setDefaultFranchiseName:(NSString*)defaultFranchiseName
{
    [_userDefaults setObject:defaultFranchiseName forKey:@"defaultFranchiseName"];
    [_userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DefaultFranchiseNameChanged" object:nil];
}

- (void)setJobToView:(NSString *)jobID
{
    [_userDefaults setObject:jobID forKey:@"jobToView"];
    [_userDefaults synchronize];
}
- (NSString *)getJobToView
{
    return [_userDefaults objectForKey:@"jobToView"];
}

- (BOOL)didUserLogout
{
    return [self getUserSessionID] == nil;
}

- (void)setUserSessionID:(NSString*)sessionID
{
    [_userDefaults setObject:sessionID forKey:@"sessionID"];
    [_userDefaults synchronize];
}

/*
 When a user logs out, the sessionID is cleared.
 If the user then login via offline key during a network outage, there is no longer a sessionID.  
 And when the network is restored, the user will immediately get logged out.
 To work around this issue, store another copy of sessionID as cachedSessionID.
 When the user enters CACHED MODE via OfflineMode, set sessionID to be the value of cachedSessionID.
 And when the user enters ACTIVE MODE via CACHED MODE, and if the sesseionID were still valid, the user can stay in ACTIVE MODE.
 This is accomplised thru the following two methods:
 -(void)cacheSessionID - store another copy of sessionID in NSUserDefault under "cachedSessionID"
 -(void)restoreSessionID - copy value in cachedSessionID into sessionID in NSUserDefault
 */
-(void)cacheSessionID
{
    [_userDefaults setObject:[self getUserSessionID] forKey:@"cachedSessionID"];
    [_userDefaults synchronize];
}

-(void)restoreSessionID
{
    if(![self getUserSessionID]){
        NSString *cachedSessionID = [_userDefaults objectForKey:@"cachedSessionID"];
        if(cachedSessionID){
            [self setUserSessionID:cachedSessionID];
        }
    }
}

- (void)setUserDefaultRouteID:(NSNumber*)routeID
{
    [_userDefaults setObject:routeID forKey:@"defaultRouteID"];
    [_userDefaults synchronize];
}

- (void)setUserDefaultFranchiseID:(NSNumber*)franchiseID
{
    [_userDefaults setObject:franchiseID forKey:@"defaultFranchiseID"];
    [_userDefaults synchronize];
}

- (void)setUserID:(NSNumber*)userID
{
    [_userDefaults setObject:userID forKey:@"userID"];
    [_userDefaults synchronize];
}

- (void)setUserLogin:(NSString*)login
{
    [_userDefaults setObject:login forKey:@"login"];
    [_userDefaults synchronize];
}
- (void)setUserPermissions:(NSString *)userPermissions
{
    [_userDefaults setObject:userPermissions forKey:@"userPermissions"];
    [_userDefaults synchronize];
}
- (void)setServerDate:(NSString*)serverDate
{
    [_userDefaults setObject:serverDate forKey:@"serverDate"];
    [_userDefaults synchronize];
}

- (void)setUserFullName:(NSString*)fullName
{
    [_userDefaults setObject:fullName forKey:@"fullName"];
    [_userDefaults synchronize];
}

- (void)setUserDefaultRouteName:(NSString*)routeName
{
    [_userDefaults setObject:routeName forKey:@"defaultRouteName"];
    [_userDefaults synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"DefaultRouteNameChanged" object:nil];
}

- (void)setUserDefaultTaxType:(NSString*)taxType
{
    [_userDefaults setObject:taxType forKey:@"defaultTaxType"];
    [_userDefaults synchronize];
}

- (void)setUserRejectJobs:(NSNumber*)jobID
{
    if ([self getUserDefaultRejectedJobs])
    {
        NSMutableArray *rejectedJobs = [[NSMutableArray alloc] initWithArray:[self getUserDefaultRejectedJobs]];
        [rejectedJobs addObject:jobID];
        [_userDefaults setObject:rejectedJobs forKey:@"rejectedJobs"];
    }
    else
    {
        NSArray *rejectedJobs = [[NSArray alloc] initWithObjects:jobID, nil];
        [_userDefaults setObject:rejectedJobs forKey:@"rejectedJobs"];
    }
    [_userDefaults synchronize];
}

- (void)setUserAcknowledgedDispatch:(NSNumber*)dispatchID
{
    NSMutableArray *acknowledgedDispatches = [[NSMutableArray alloc] initWithArray:[self getUserAcknowledgedDispatches]];
    if (acknowledgedDispatches)
    {
        // check if this dispatch exists in the acknowledged-dispatch queue already
        if (![self didUserAcknowledgeDispatch:dispatchID])
        {
            [acknowledgedDispatches addObject:dispatchID];
        }
    }
    else
    {
        acknowledgedDispatches = [[NSMutableArray alloc] initWithObjects:dispatchID,nil];
    }
    [_userDefaults setObject:acknowledgedDispatches forKey:@"acknowledgedDispatches"];
    [_userDefaults synchronize];
}

- (void)flushUserAcknowledgedDispatches
{
    [_userDefaults setObject:nil forKey:@"acknowledgedDispatches"];
    [_userDefaults synchronize];
}

- (void)markJobAsSeenButNotAccepted:(NSNumber*)jobID
{
    if ([self getJobsUserHasSeenAndNotAccepted])
    {
        NSMutableDictionary *jobs = [[NSMutableDictionary alloc] initWithDictionary:[self getJobsUserHasSeenAndNotAccepted]];
        [jobs setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%d", [jobID integerValue]]];
        [_userDefaults setObject:jobs forKey:@"jobsSeenAndNotAccepted"];
    }
    else
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], [NSString stringWithFormat:@"%d", [jobID integerValue]], nil];
        [_userDefaults setObject:dict forKey:@"jobsSeenAndNotAccepted"];
    }
    
    [_userDefaults synchronize];
}

- (void)setFeedbackEmail:(NSString*)feedbackEmail
{
    [_userDefaults setObject:feedbackEmail forKey:@"feedbackEmail"];
    [_userDefaults synchronize];
}

- (NSDate *)getDateAcknowledgedDispatchesCleared
{
    NSDate *clearDate = [_userDefaults objectForKey:@"dateAcknowledgedDispatchesCleared"];
    if (clearDate)
    {
        return clearDate;
    }
    else
    {
        return nil;
    }
    
}

- (void)setDateAcknowledgedDispatchesCleared:(NSDate *)clearDate;
{
    [_userDefaults setObject:clearDate forKey:@"dateAcknowledgedDispatchesCleared"];
    [_userDefaults synchronize];
}

- (BOOL)didClearAcknowledgedDispatchesToday
{
    NSDate *clearDate = [self getDateAcknowledgedDispatchesCleared];
    
    // if this date is sometime today >= midnight, then return yes.
    if (!clearDate){
        return NO;
    }
    
    NSDate *midnight = [DateHelper midnightToday];
    
    NSComparisonResult result = [clearDate compare:midnight];
    
    
    if (result == NSOrderedAscending){ // has not yet been cleared today
        return NO;
    } else { // was cleared either right on or after midnight
        return YES;
    }
}

# pragma mark - String Loading

+ (NSString *)loadStringFromFile:(NSString *)filename
                            type:(NSString *)filetype
{
    NSStringEncoding utf8 = NSUTF8StringEncoding;
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:filename
                                                                          ofType:filetype];
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile: filePath
                                                  usedEncoding: &utf8
                                                         error: &error
                             ];
    
    return fileContent;
}

# pragma mark - App Version

+ (NSString *)appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

+ (NSString *)build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

# pragma mark - OS

+ (NSString *)osVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSDictionary*)getUserObject
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[self getUserSessionID] forKey:@"sessionID"];
    [dict setObject:[self getUserID] forKey:@"userID"];
    [dict setObject:[self getUserPermissions] forKey:@"permissions"];
    [dict setObject:[self getUserFullName] forKey:@"fullName"];
    [dict setObject:[self getUserDefaultFranchiseName] forKey:@"defaultFranchise"];
    [dict setObject:[self getUserDefaultRouteID] forKey:@"defaultRouteID"];
    [dict setObject:[self getUserDefaultRouteName] forKey:@"defaultRoute"];
    [dict setObject:[self getUserDefaultFranchiseID] forKey:@"defaultFranchiseID"];

    return dict;
}

@end
