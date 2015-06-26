//
//  Job.h
//  GOT-JUNK
//
//  Created by epau on 1/31/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MapPoint;

enum {
    JobTypeResidential = 1,
    JobTypeCommercial = 2,
    JobTypeBookOff = 3,
    JobTypeEstimate = 4,
};
typedef NSUInteger JobType;

@interface Job : NSObject

@property (nonatomic, strong) NSNumber *callAheadTime;
@property (nonatomic, strong) NSNumber *jobID;
@property (nonatomic, strong) NSString *callAheadStatus;
@property (nonatomic, strong) NSString *clientCompany;
@property (nonatomic, strong) NSString *clientName;
@property (nonatomic, strong) NSString *clientEmail;
@property (nonatomic, strong) NSString *contactHomeAreaCode;
@property (nonatomic, strong) NSString *contactHomeExt;
@property (nonatomic, strong) NSString *contactHomePhone;
@property (nonatomic, strong) NSString *contactPagerExt;
@property (nonatomic, strong) NSString *contactPagerAreaCode;
@property (nonatomic, strong) NSString *contactPagerPhone;
@property (nonatomic, strong) NSString *contactWorkExt;
@property (nonatomic, strong) NSString *contactWorkAreaCode;
@property (nonatomic, strong) NSString *contactWorkPhone;
@property (nonatomic, strong) NSString *contactFax;
@property (nonatomic, strong) NSString *contactFaxExt;
@property (nonatomic, strong) NSString *contactFaxAreaCode;
@property (nonatomic, strong) NSString *contactCell;
@property (nonatomic, strong) NSString *contactCellExt;
@property (nonatomic, strong) NSString *contactCellAreaCode;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) NSString *promiseTime;
@property (nonatomic, strong) NSDate *jobDate;
@property (nonatomic, strong) NSString *jobDateAsString;
@property (nonatomic, strong) NSString *jobDuration;
@property (nonatomic, strong) NSString *jobStartTime;
@property (nonatomic, strong) NSString *jobEndTime;
@property (nonatomic, strong) NSString *pickupAddress;
@property (nonatomic, strong) NSNumber *taxID;
@property (nonatomic, strong) NSNumber *contactID;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSNumber *discount;
@property (nonatomic, strong) NSString *pickupCountry;

@property (nonatomic, strong) NSString *invoiceNumber;
@property (nonatomic, strong) NSNumber *paymentID;
@property (nonatomic, strong) NSNumber *subTotal;
@property (nonatomic, strong) NSNumber *programDiscount;
@property (nonatomic, strong) NSString *programDiscountType;
@property (nonatomic, strong) NSString *promoCode;
@property (nonatomic, strong) NSString *zoneColor;
@property (nonatomic, strong) NSString *zoneFontColor;

@property (nonatomic, strong) NSString *dispatchMessage;
@property (nonatomic, strong) NSString *programNotes;
@property (nonatomic, strong) NSString *taxType;
@property (nonatomic) BOOL dispatchAccepted;
@property (nonatomic, strong) NSNumber *typeID;
@property (nonatomic, strong) NSNumber *clientTypeID;
@property (nonatomic, strong) NSNumber *jobStartTimeOriginal;
@property (nonatomic, strong) NSNumber *numOfJobs;
@property (nonatomic, strong) NSNumber *jobType;
@property (nonatomic, strong) NSNumber *junkCharge;
@property (nonatomic, strong) NSNumber *contactPhonePrefID;
@property (nonatomic, strong) NSString *contactPhonePref;
@property (nonatomic, strong) NSNumber *onSiteContactID;
@property (nonatomic, strong) NSNumber *taxAmount;
@property (nonatomic, strong) NSNumber *totalSpent;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *pickupCompany;
@property (nonatomic, strong) NSString *zoneName;
@property (nonatomic, strong) NSString *onSiteContactAreaCode;
@property (nonatomic, strong) NSString *onSiteContactPhone;
@property (nonatomic, strong) NSString *onSiteContactExt;
@property (nonatomic, strong) NSString *onSiteContactPhonePrefID;
@property (nonatomic, strong) NSString *onSiteContactPhonePref;
@property (nonatomic, strong) NSString *nameOfLastTTUsed;
@property (nonatomic, strong) NSString *npsComment;
@property (nonatomic, strong) NSNumber *npsValue;
@property (nonatomic) BOOL isEnviroRequired;
@property (nonatomic) BOOL isCentrallyBilled;
@property (nonatomic) BOOL isCashedOut;

@property (nonatomic, strong) NSDictionary *apiJob;
@property (nonatomic, strong) NSString *junkLocationComments;
@property (nonatomic, strong) NSString *jobComments;
@property (nonatomic, strong) MapPoint *mapPoint;
@property (nonatomic, strong) NSNumber *dispatchID;
@property (nonatomic, strong) NSNumber *isDispatchAccepted;
@property (nonatomic, strong) NSNumber *routeID;

- (BOOL)isBookoff;
- (void)parseOutLocationComments;
- (void)appendCommentsAndJunkLocation:(NSString*)comments;
- (BOOL)isDispatchJob;
- (BOOL)isDispatchJobAccepted;

+ (void)updateValuesOfJob:(Job *)oldJob withNewJob:(Job *)newJob;

@end
