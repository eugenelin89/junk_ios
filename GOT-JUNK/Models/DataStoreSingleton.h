//
//  DataStoreSingleton.h
//  GOT-JUNK
//
//  Created by epau on 1/31/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Expense.h"
#import "PaymentMethod.h"
#import "Lookup.h"
#import "Resource.h"

#define COREDATAREADY_NOTIFICATION @"COREDATAREADY_NOTIFICATION"
#define DISCONNECTED_NOTIFICATION @"DISCONNECTED_NOTIFICATION"       // disconnect
#define RECONNECTED_NOTIFICATION @"RECONNECTED_NOTIFICATION"         // reconnect
#define LOGGEDOUT_NOTIFICATION @"LOGGEDOUT_NOTIFICATION"             // logged out
#define LOGGEDIN_NOTIFICATION @"LOGGEDIN_NOTIFICATION"               // logged in
#define LOGINFAILED_NOTIFICATION @"LOGINFAILED_NOTIFICATION"         // attempt to login failed.
#define JOBSTIMESTAMPUPDATE_NOTIFICATION @"JOBSTIMESTAMPUPDATE_NOTIFICATION" // timestamp updated
#define FETCHJOBLISTFORROUTEFAILED_NOTIFICATION @"FETCHJOBLISTFORROUTEFAILED_NOTIFICATION" // fetchJobListForRoute:andDate:withAlert failed

@class Route;
@class Franchise;
@class Job;

@interface DataStoreSingleton : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *loadTypeSizeList;
@property (nonatomic, strong) NSMutableArray *lookupList;
@property (nonatomic, strong) NSMutableArray *enviroDestinationsList;
@property (nonatomic, strong) NSMutableArray *junkTypesList;
@property (nonatomic, strong) NSArray *jobList;
@property (nonatomic, strong) NSArray *routeList;
@property (nonatomic, strong) NSArray *taxList;
@property (nonatomic, strong) NSArray *paymentMethodList;
@property (nonatomic, strong) NSArray *franchiseList;
@property (nonatomic, strong) NSMutableArray *paymentList;
@property (nonatomic, strong) NSMutableArray *dispatchesList;
@property (nonatomic, strong) NSMutableArray * resourcesList;
@property (nonatomic, strong) NSMutableArray * mapPointsList;
@property (nonatomic, strong) NSMutableArray * jobsPointsList;
@property (nonatomic, strong) NSMutableArray * gasPointsList;
@property (nonatomic, strong) NSMutableArray * depotsPointsList;

@property (nonatomic, strong) NSArray *assignedRoutes;

@property (nonatomic, strong) NSDictionary *expensesDict;
@property (nonatomic, strong) NSMutableArray *expenseAccountsList;
@property (nonatomic, strong) NSMutableDictionary *enviroDict;
@property (nonatomic, strong) NSString * permissions;

@property (nonatomic, strong) NSString * currentLookupMode;
@property (nonatomic, strong) Lookup * currentLookup;
@property (nonatomic, strong) Expense *currentExpense;
@property (nonatomic, strong) Resource *currentResource;

@property (nonatomic, strong) PaymentMethod *currentPaymentMethod;

@property (nonatomic, strong) Route *currentRoute;
@property (nonatomic, strong) Franchise *currentFranchise;
@property (nonatomic, strong) NSNumber *currentJobPaymentID;

@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic) BOOL minutesTilAlert;

@property (nonatomic, strong) Job *pushJob;
@property (nonatomic, strong) NSMutableDictionary *routeJobs;
@property (nonatomic) BOOL isUserLoggedIn;
@property (nonatomic) BOOL isConnected;
@property (nonatomic, strong) NSString *paymentErrors;
@property (nonatomic, strong) NSDictionary *appUpgradeInfo;

@property (nonatomic, strong) NSString *debugDisplayText1;
@property (nonatomic, strong) NSString *debugDisplayText2;

@property (nonatomic, strong) NSMutableArray *notificationList;
@property (nonatomic, strong) Job *currentJob;
@property (nonatomic, strong) Route *filterRoute;
@property (nonatomic, strong) NSDate *jobsLastUpdateTime;


+ (DataStoreSingleton *)sharedInstance;
-(void)addExpense:(Expense *)expense expenseTypeID:(int)et;
- (void)mergeJobs:(NSArray *)jobs;
-(void)deleteAllData;
- (void)setPendingDispatches:(NSInteger)badgeCount;
- (void)setCurrentJobPaymentID:(NSNumber *)jobID;
- (void)decrementPendingDispatches;
- (void)getJobListForCachedCurrentRoute;
- (void)addJobsList:(NSArray*)jobListArray forRoute:(NSNumber*)routeID;
- (void)clearRouteJobs;

- (void)parseEnviroDict:(NSString*)responseString;
- (void)parseExpenseDict:(NSString*)responseString;
- (void)parsePaymentDict:(NSString*)responseString;
- (void)parseJobDict:(NSString*)responseString;
- (void)parseJobListDict:(NSString*)responseString routeID:(NSNumber*)routeID;
- (NSArray*)mergeJobsDict:(NSString*)responseString;

- (void)setEnviroDictFromJSON:(NSString*)responseString withJobID:(int)jobID;
- (Job*)jobFromJsonString:(NSString *)jsonString;

- (void)decrementCurrentNotificationPageNumber;
- (void)incrementCurrentNotificationPageNumber;
- (int)getCurrentNotificationPageNumber;
- (Job*)getJob:(int)jobId;
- (Job*)mapJob:(NSDictionary*)dict; // Map a NSDictionary to Job
-(void)removeJobsInLocalPersistentStoreForDate:(NSDate*) date forRoute:(NSNumber*)routeID;
-(void)removeJobsInLocalPersistentStoreForDate:(NSDate*)fromDate toDate:(NSDate*)toDate forRoute:(NSNumber*)routeID;


@end
