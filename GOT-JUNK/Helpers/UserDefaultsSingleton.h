//
//  UserDefaultsSingleton.h
//  GOT-JUNK
//
//  Created by epau on 1/30/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>


@interface UserDefaultsSingleton : NSObject
{
@private
    NSUserDefaults *_userDefaults;
}

+ (UserDefaultsSingleton *)sharedInstance;

- (BOOL)isFirstTimeInstall;
- (void)setInstalled;

- (void)clearAllData;

- (NSString*)getUserSessionPermissionsPath;

- (NSString*)getUserSessionID;
- (NSString *)getUserDefaultFranchiseName;
- (NSNumber*)getUserDefaultRouteID;
- (NSNumber*)getUserDefaultFranchiseID;
- (NSNumber*)getUserID;
- (NSString *)getUserLogin;
- (NSString*)getUserFullName;
- (NSString*)getUserDefaultRouteName;
- (NSDictionary*)getJobsUserHasSeenAndNotAccepted;
- (NSString*)getFeedbackEmail;
- (NSString*)getUserDefaultTaxType;
- (NSString*)getUserPermissions;
- (NSString*)getServerDate;
- (NSMutableArray *)getUserAcknowledgedDispatches;
- (void)setJobToView:(NSString *)jobID;
- (NSString *)getJobToView;
- (BOOL)isOfflineAuthorized;
- (void)setColorPreference:(BOOL)isOn;
- (BOOL)getUserColorPref;
- (BOOL)setMapSwitch:(BOOL)isOn;
- (BOOL)getUseGoogleMaps;
- (BOOL)didUserRejectJobWithID:(NSNumber*)jobID;
- (BOOL)didUserAcknowledgeDispatch:(NSNumber*)dispatchID;
- (BOOL)didClearAcknowledgedDispatchesToday;
- (NSDate *)getDateAcknowledgedDispatchesCleared;
- (NSDate *)getDateLastCheckedUpdate;
- (void)offlineModeEnabled;
- (void)offlineModeDisabled;
- (void)storeOfflineKey:(NSString * )myKey;
- (void)setUserSessionID:(NSString*)sessionID;
- (void)cacheSessionID;
- (void)restoreSessionID;
- (void)setJobsLastUpdateTime:(NSDate*)timeStamp;
- (NSDate*)jobsLastUpdateAt;
- (void)setUserDefaultRouteID:(NSNumber*)routeID;
- (void)setUserDefaultFranchiseID:(NSNumber*)franchiseID;
- (void)setUserID:(NSNumber*)userID;
- (void)setUserLogin:(NSString *)userLogin;
- (void)setUserPermissions:(NSString *)userPermissions;
- (void)setUserFullName:(NSString*)fullName;
- (void)setUserDefaultRouteName:(NSString*)routeName;
- (void)setServerDate:(NSString*)serverDate;
- (void)markJobAsSeenButNotAccepted:(NSNumber*)jobID;
- (void)setFeedbackEmail:(NSString*)feedbackEmail;
- (void)setUserDefaultTaxType:(NSString*)taxType;
- (void)setUserAcknowledgedDispatch:(NSNumber *)dispatchID;
- (void)flushUserAcknowledgedDispatches;
+ (NSString *)loadStringFromFile:(NSString *)filename
                            type:(NSString *)filetype;
- (void)setDefaultFranchiseName:(NSString*)defaultFranchiseName;
+ (NSString *)build;
+ (NSString *)appVersion;
+ (NSString *)osVersion;
- (void)setDateAcknowledgedDispatchesCleared:(NSDate *)clearDate;
- (BOOL)didUserLogout;
- (NSDictionary*)getUserObject;

-(void)setDeviceID:(NSString*)deviceID;
-(NSString*)getDeviceID;
-(void)setLastKnownLocation:(CLLocationCoordinate2D)coordinate;
-(CLLocationCoordinate2D) getLastKnownLocation;


@end
