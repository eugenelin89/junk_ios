//
//  CDJob.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-26.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDRoute;

@interface CDJob : NSManagedObject

@property (nonatomic, retain) NSString * callAheadStatus;
@property (nonatomic, retain) NSNumber * callAheadTime;
@property (nonatomic, retain) NSString * clientCompany;
@property (nonatomic, retain) NSString * clientEmail;
@property (nonatomic, retain) NSString * clientName;
@property (nonatomic, retain) NSNumber * clientTypeID;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * contactCell;
@property (nonatomic, retain) NSString * contactCellAreaCode;
@property (nonatomic, retain) NSString * contactCellExt;
@property (nonatomic, retain) NSString * contactFax;
@property (nonatomic, retain) NSString * contactFaxAreaCode;
@property (nonatomic, retain) NSString * contactFaxExt;
@property (nonatomic, retain) NSString * contactHomeAreaCode;
@property (nonatomic, retain) NSString * contactHomeExt;
@property (nonatomic, retain) NSString * contactHomePhone;
@property (nonatomic, retain) NSNumber * contactID;
@property (nonatomic, retain) NSString * contactPagerAreaCode;
@property (nonatomic, retain) NSString * contactPagerExt;
@property (nonatomic, retain) NSString * contactPagerPhone;
@property (nonatomic, retain) NSString * contactPhonePref;
@property (nonatomic, retain) NSNumber * contactPhonePrefID;
@property (nonatomic, retain) NSString * contactWorkAreaCode;
@property (nonatomic, retain) NSString * contactWorkExt;
@property (nonatomic, retain) NSString * contactWorkPhone;
@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSNumber * dispatchAccepted;
@property (nonatomic, retain) NSNumber * dispatchID;
@property (nonatomic, retain) NSString * dispatchMessage;
@property (nonatomic, retain) NSString * invoiceNumber;
@property (nonatomic, retain) NSNumber * isCashedOut;
@property (nonatomic, retain) NSNumber * isCentrallyBilled;
@property (nonatomic, retain) NSNumber * isDispatchAccepted;
@property (nonatomic, retain) NSNumber * isEnviroRequired;
@property (nonatomic, retain) NSString * jobComments;
@property (nonatomic, retain) NSDate * jobDate;
@property (nonatomic, retain) NSNumber * jobDuration;
@property (nonatomic, retain) NSString * jobEndTime;
@property (nonatomic, retain) NSNumber * jobID;
@property (nonatomic, retain) NSString * jobStartTime;
@property (nonatomic, retain) NSNumber * jobStartTimeOriginal;
@property (nonatomic, retain) NSNumber * jobType;
@property (nonatomic, retain) NSNumber * junkCharge;
@property (nonatomic, retain) NSString * junkLocationComments;
@property (nonatomic, retain) NSString * nameOfLastTTUsed;
@property (nonatomic, retain) NSString * npsComment;
@property (nonatomic, retain) NSNumber * npsValue;
@property (nonatomic, retain) NSNumber * numOfJobs;
@property (nonatomic, retain) NSString * onSiteContactAreaCode;
@property (nonatomic, retain) NSString * onSiteContactExt;
@property (nonatomic, retain) NSNumber * onSiteContactID;
@property (nonatomic, retain) NSString * onSiteContactPhone;
@property (nonatomic, retain) NSString * onSiteContactPhonePref;
@property (nonatomic, retain) NSNumber * onSiteContactPhonePrefID;
@property (nonatomic, retain) NSNumber * paymentID;
@property (nonatomic, retain) NSString * pickupAddress;
@property (nonatomic, retain) NSString * pickupCompany;
@property (nonatomic, retain) NSString * pickupCountry;
@property (nonatomic, retain) NSNumber * programDiscount;
@property (nonatomic, retain) NSString * programDiscountType;
@property (nonatomic, retain) NSString * programNotes;
@property (nonatomic, retain) NSString * promiseTime;
@property (nonatomic, retain) NSString * promoCode;
@property (nonatomic, retain) NSNumber * subTotal;
@property (nonatomic, retain) NSNumber * taxAmount;
@property (nonatomic, retain) NSNumber * taxID;
@property (nonatomic, retain) NSString * taxType;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * totalSpent;
@property (nonatomic, retain) NSNumber * typeID;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * zoneColor;
@property (nonatomic, retain) NSString * zoneFontColor;
@property (nonatomic, retain) NSString * zoneName;
@property (nonatomic, retain) CDRoute *route;

@end
