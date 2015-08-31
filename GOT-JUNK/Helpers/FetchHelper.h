//
//  FetchHelper.h
//  GOT-JUNK
//
//  Created by epau on 1/30/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Job.h"
#import "Expense.h"

typedef NS_ENUM(NSInteger, SubmitMode)
{
    SubmitModeExpense,
    SubmitModeResource
};

@interface FetchHelper : NSObject

+(FetchHelper *)sharedInstance;

- (void)login:(NSString*)username withPassword:(NSString*)password;
- (void)getSystemInfo;
- (void)fetchLookup:(NSString *)mode itemID:(int)i languageID:(int)l userID:(int)u;
- (void)fetchLoadTypeSizes;
- (void)fetchResources:(int)resourceTypeID;
- (void)fetchExpensesByRoute:(int)routeID onDate:(NSDate *)date;
- (void)fetchJobListForRoute:(NSNumber*)routeID andDate:(NSDate *)date withAlert:(BOOL)shouldShowAlert;
- (void)fetchJobListsForAllRoutes:(bool)isForwardCache; // used for initial caching of data and forward caching
- (void)fetchRouteList;
- (void)fetchFranchiseList;
- (void)fetchJobDetaislForJob:(NSNumber*)jobID;
- (void)fetchExpenseAccountsList:(int)expenseTypeID;
- (void)fetchTaxTypes;
- (void)fetchPaymentMethods;
- (void)fetchJunkTypes;
- (void)fetchExpensePaymentMethods; 
- (void)fetchEnviroByRoute:(int)routeID onDate:(NSDate *)date;
- (void)fetchDispatchesByRoute;
- (void)sendInvoice:(Job*)job paymentMethod:(NSInteger)pm junkCharge:(NSInteger)jc discount:(NSInteger)dc invoiceNumber:(NSInteger)inum taxID:(NSInteger)taxID;
- (void)updateEmail:(NSString*)email forJob:(Job*)job;
- (void)updateNote:(NSString*)comment forJob:(Job*)job;
- (void)acceptDispatchForJob:(Job*)job;
- (void)fetchPaymentsByJob:(int)jobID;
- (void)fetchEnviroDestinations;
- (void)convertEstimate:(Job*)job;
- (void)fetchJobListForDefaultRouteAndCurrentDate;

- (void)checkAppUpgrade;
- (void)getAllCachingData;
- (void)clearUsernamePassword;
- (void)clearChannels;

- (void)saveEnviro:(NSArray *)enviroArray isDeletion:(BOOL)isDelete forJobID:(int)jID;
- (void)postExpense:(NSString *)path withParams:(NSDictionary *)params;
- (void)putExpenseResource:(NSString *)path withParams:(NSDictionary *)params withMode:(SubmitMode)mode;
- (void)updateContactPhone:(NSNumber *)jobID withParams:(NSDictionary *)params;
- (void)setDispatchStatus:(int)dispatchID;
- (void)updateJob:(NSNumber*)jobID withDuration:(NSNumber*)jobDuration;
- (void)copyMoveJob:(NSNumber*)jobID jobType:(NSString*)jobType routeID:(NSInteger)routeID jobStartTimeOriginal:(NSNumber*)jobStartTimeOriginal;
- (void)deleteExpense:(Expense*)expenseToDelete withIndexPath:(NSIndexPath*)indexPath;
- (void)cancelJob:(NSNumber*)jobID withReason:(int)reasonID periodID:(int)periodID comments:(NSString*)comments;
- (void)setCallStatus:(NSNumber*)jobID statusID:(NSString*)senderString;
- (void)postPayment:(NSString*)path params:(NSDictionary*)params;

- (void)fetchResourcesALL:(int)franchiseIndex;
- (void)fetchNotifications;

@end
