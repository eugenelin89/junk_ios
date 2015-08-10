//
//  CDJob+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob+GotJunk.h"
#import "CDRoute+GotJunk.h"
#import "CDMapPoint+GotJunk.h"
#import "../job.h"
#import "../DataStoreSingleton.h"
#import "../MapPoint.h"
#import "../DateHelper.h"
//#import "CDUser+GotJunk.h"
//#import "UserDefaultsSingleton.h"

@implementation CDJob (GotJunk)

+(CDJob*) job:(Job *)job inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDJob *cdjob = nil;
    
    NSNumber *jobID = job.jobID;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobID = %@", jobID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || [matches count] > 1){
        // handle error
    }else if([matches count]){
        // Update Job
        NSLog(@"Already exists: %@", job.jobID);
        cdjob = [matches lastObject];
        if([cdjob.routeID integerValue] != [job.routeID integerValue]){
            // this job is switching route.  need to remove this job from route
            CDRoute * oldRoute = [CDRoute getRouteWithID:cdjob.routeID inManagedObjectContext:context];
            [oldRoute removeJobsObject:cdjob];
        }
    }else{
        // create it in DB
        NSLog(@"Adding Job ID: %@", job.jobID);
        cdjob = [NSEntityDescription insertNewObjectForEntityForName:@"CDJob" inManagedObjectContext:context];
        cdjob.jobID = jobID; // no null value
    }
    
    cdjob.routeID = job.routeID; // no null value
    cdjob.clientName = [job.clientName isKindOfClass:[NSString class]] ? job.clientName : @"";
    cdjob.jobDate = job.jobDate; // no null value
    cdjob.callAheadStatus = [cdjob.callAheadStatus isKindOfClass:[NSString class]] ? job.callAheadStatus : @"";
    cdjob.callAheadTime = job.callAheadTime; // always nil
    cdjob.clientCompany = [job.clientCompany isKindOfClass:[NSString class]] ? job.clientCompany : @"";
    cdjob.clientEmail = [job.clientEmail isKindOfClass:[NSString class]] ? job.clientEmail : @"";
    cdjob.clientTypeID = job.clientTypeID; // no null value
    cdjob.comments = [job.comments isKindOfClass:[NSString class]] ? job.comments : @"";
    cdjob.contactCell = [job.contactCell isKindOfClass:[NSString class]] ? job.contactCell : @"";
    cdjob.contactCellAreaCode = [job.contactCellAreaCode isKindOfClass:[NSString class]] ? job.contactCellAreaCode : @"";
    cdjob.contactCellExt = [job.contactCellExt isKindOfClass:[NSString class]] ? job.contactCellExt : @"";
    cdjob.contactFax = [job.contactFax isKindOfClass:[NSString class]] ? job.contactFax : @"";
    cdjob.contactFaxAreaCode = [job.contactFaxAreaCode isKindOfClass:[NSString class]] ? job.contactFaxAreaCode : @"";
    cdjob.contactFaxExt = [job.contactFaxExt isKindOfClass:[NSString class]] ? job.contactFaxExt : @"";
    cdjob.contactHomeAreaCode = [job.contactHomeAreaCode isKindOfClass:[NSString class]] ? job.contactHomeAreaCode : @"";
    cdjob.contactHomeExt = [job.contactHomeExt isKindOfClass:[NSString class]]? job.contactHomeExt : @"";
    cdjob.contactHomePhone = [job.contactHomePhone isKindOfClass:[NSString class]] ? job.contactHomePhone : @"";
    cdjob.contactID = job.contactID; // no null value
    cdjob.contactPagerAreaCode = [job.contactPagerAreaCode isKindOfClass:[NSString class]] ? job.contactPagerAreaCode : @"";
    cdjob.contactPagerExt = [job.contactPagerExt isKindOfClass:[NSString class]] ? job.contactPagerExt : @"";
    cdjob.contactPagerPhone = [job.contactPagerPhone isKindOfClass:[NSString class]] ? job.contactPagerPhone : @"";
    cdjob.contactPhonePref = [job.contactPhonePref isKindOfClass:[NSString class]] ? job.contactPhonePref : @"";
    cdjob.contactPhonePrefID = job.contactPhonePrefID; // no null value
    cdjob.contactWorkAreaCode = [job.contactWorkAreaCode isKindOfClass:[NSString class]] ? job.contactWorkAreaCode : @"";
    cdjob.contactWorkExt = [job.contactWorkExt isKindOfClass:[NSString class]] ? job.contactWorkExt : @"";
    cdjob.contactWorkPhone = [job.contactWorkPhone isKindOfClass:[NSString class]] ? job.contactWorkPhone : @"";
    cdjob.discount = job.discount; // no null value
    cdjob.dispatchAccepted = [NSNumber numberWithBool:job.dispatchAccepted]; // should be isDispatchAccepted? dispatchAccepted always nil which turns into 0
    cdjob.dispatchID = job.dispatchID; // no null value
    cdjob.dispatchMessage = [job.dispatchMessage isKindOfClass:[NSString class]] ? job.dispatchMessage : @"";
    cdjob.invoiceNumber = [cdjob.invoiceNumber isKindOfClass:[NSString class]] ? job.invoiceNumber : @"";
    cdjob.isCashedOut = [NSNumber numberWithBool:job.isCashedOut]; // no null value
    cdjob.isCentrallyBilled = [NSNumber numberWithBool:job.isCentrallyBilled]; // no null value
    cdjob.isDispatchAccepted = job.isDispatchAccepted; // no null value
    cdjob.isEnviroRequired = [NSNumber numberWithBool:job.isEnviroRequired]; // no null value
    cdjob.jobComments = [job.jobComments isKindOfClass:[NSString class]]? job.jobComments : @"";
    cdjob.jobDate = job.jobDate; // no null value
    cdjob.jobDuration = [NSNumber numberWithInt:[job.jobDuration integerValue]]; // Guranteed to be NSString
    cdjob.jobEndTime = [job.jobEndTime isKindOfClass:[NSString class]] ? job.jobEndTime : @"";
    cdjob.jobStartTime = [job.jobStartTime isKindOfClass:[NSString class]] ? job.jobStartTime : @"";
    cdjob.jobStartTimeOriginal = job.jobStartTimeOriginal; // no null value
    cdjob.jobType = job.jobType; // no null value
    cdjob.junkCharge = job.junkCharge; // no null value
    cdjob.junkLocationComments = [job.junkLocationComments isKindOfClass:[NSString class]] ? job.junkLocationComments : @"";
    cdjob.nameOfLastTTUsed = [job.nameOfLastTTUsed isKindOfClass:[NSString class]] ? job.nameOfLastTTUsed : @"";
    cdjob.npsComment = [job.npsComment isKindOfClass:[NSString class]]? job.npsComment : @"";
    cdjob.npsValue = job.npsValue; // no null value
    cdjob.numOfJobs = job.numOfJobs; // no null value
    cdjob.onSiteContactAreaCode = [job.onSiteContactAreaCode isKindOfClass:[NSString class]] ? job.onSiteContactAreaCode : @"";
    cdjob.onSiteContactExt = [cdjob.onSiteContactExt isKindOfClass:[NSString class]] ? job.onSiteContactExt : @"";
    cdjob.onSiteContactID = [job.onSiteContactID isKindOfClass:[NSNumber class]]? job.onSiteContactID : [NSNumber numberWithInt:0];
    cdjob.onSiteContactPhone = [job.onSiteContactPhone isKindOfClass:[NSString class]]? job.onSiteContactPhone : @"";
    cdjob.onSiteContactPhonePref = [job.onSiteContactPhonePref isKindOfClass:[NSString class]]? job.onSiteContactPhonePref : @"";
    cdjob.onSiteContactPhonePrefID =[job.onSiteContactPhonePrefID isKindOfClass:[NSString class]]? [NSNumber numberWithInt: [job.onSiteContactPhonePrefID integerValue]] : [NSNumber numberWithInt:0]; // job.onSiteContactPhonePrefID is type NSString
    cdjob.paymentID = job.paymentID; // no null value
    cdjob.pickupAddress = [job.pickupAddress isKindOfClass:[NSString class]] ? job.pickupAddress :@"";
    cdjob.pickupCompany = [cdjob.pickupCompany isKindOfClass:[NSString class]]? job.pickupCompany : @"";
    cdjob.pickupCountry = [job.pickupCountry isKindOfClass:[NSString class]]? job.pickupCountry : @"";
    cdjob.programDiscount = job.programDiscount; // no null value
    cdjob.programDiscountType = [job.programDiscountType isKindOfClass:[NSString class]]? job.programDiscountType : @"";
    cdjob.programNotes = [job.programNotes isKindOfClass:[NSString class]] ? job.programNotes : @"";
    cdjob.promiseTime = [job.promiseTime isKindOfClass:[NSString class]]? job.promiseTime : @"";
    cdjob.promoCode = [job.promoCode isKindOfClass:[NSString class]]? job.promoCode : @"";
    cdjob.subTotal = job.subTotal; // no null value
    cdjob.taxAmount = job.taxAmount; // no null value
    cdjob.taxID = job.taxID; // no null value
    cdjob.taxType = [job.taxType isKindOfClass:[NSString class]]? job.taxType : @"";
    cdjob.total = [NSNumber numberWithInt:[job.total integerValue]]; // no nulll value
    cdjob.totalSpent = job.totalSpent; // no null value
    cdjob.typeID = job.typeID; // no null value
    cdjob.zipCode = [job.zipCode isKindOfClass:[NSString class]]? job.zipCode : @"";
    cdjob.zoneColor = [job.zoneColor isKindOfClass:[NSString class]]?job.zoneColor : @"";
    cdjob.zoneFontColor =[job.zoneFontColor isKindOfClass:[NSString class]]? job.zoneFontColor : @"";
    cdjob.zoneName = [job.zoneName isKindOfClass:[NSString class]]?job.zoneName :@"";

    
    CDRoute *cdRoute = [CDRoute routeWithID:job.routeID inManagedObjectContext:context];
    [cdRoute addJobsObject:cdjob];
    

    //CDUser * cdUser = [CDUser userWithID:[[UserDefaultsSingleton sharedInstance] getUserID] inManagedObjectContext:context]; TEST
    
    return cdjob;
}

+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context
{
    // will need to fix this.  testing for now.
    for(Job *job in jobs){
        [self job:job inManagedObjectContext:context];
    }
    
    NSLog(@"Finished adding jobs to Core Data\n\n\n");

}

+(void)deleteJobsForDate:(NSDate*)date forRoute:(NSNumber*)routeID inManagedContext:(NSManagedObjectContext*)context
{

    NSDate *todayStart = [DateHelper dayStart:date];
    NSDate *todayEnd = [DateHelper dayEnd:date];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobDate >= %@ AND jobDate <= %@ AND routeID = %@", todayStart, todayEnd, routeID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error){
        // Handle Error
        NSLog(@"ERROR retrieving jobs from core data (deleteJobsForDate): %@", error);
    }else{
        // remove them all
        for(CDJob* job in matches){
            [context deleteObject:job];
        }
    }
    
}

+(NSArray *)jobsForDate:(NSDate*)date forRoute:(NSNumber*)routeID InManagedContext:(NSManagedObjectContext*)context
{
    NSDate *todayStart = [DateHelper dayStart:date];
    NSDate *todayEnd = [DateHelper dayEnd:date];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobDate >= %@ AND jobDate <= %@ AND routeID = %@", todayStart, todayEnd, routeID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSMutableArray *tempArray;
    
    if(!matches || error){
        // Handle Error
        NSLog(@"ERROR retrieving jobs from core data (jobsForDate): %@", error);
    }else{
        NSLog(@"Retrieved %d jobs from core data", [matches count]);
        tempArray = [[NSMutableArray alloc] initWithCapacity:[matches count]];
        for(CDJob *cdjob in matches){
            // Convert each job into a JOB object and add to the array
            
            [tempArray addObject:[CDJob toJobWithCDJob: cdjob]];

        }
    }
    return tempArray;
}

+(Job *) toJobWithCDJob:(CDJob *)cdjob
{
    Job *aJob = [[Job alloc] init];
    aJob.jobID = cdjob.jobID;
    aJob.routeID = cdjob.routeID;
    aJob.clientName = cdjob.clientName;
    aJob.jobDate = cdjob.jobDate;
    aJob.callAheadStatus = cdjob.callAheadStatus;
    aJob.callAheadTime = cdjob.callAheadTime;
    aJob.clientCompany = cdjob.clientCompany;
    aJob.clientEmail = cdjob.clientEmail;
    aJob.clientTypeID = cdjob.clientTypeID;
    aJob.comments = cdjob.comments;
    aJob.contactCell = cdjob.contactCell;
    aJob.contactCellAreaCode = cdjob.contactCellAreaCode;
    aJob.contactCellExt = cdjob.contactCellExt;
    aJob.contactFax = cdjob.contactFax;
    aJob.contactFaxAreaCode = cdjob.contactFaxAreaCode;
    aJob.contactFaxExt = cdjob.contactFaxExt;
    aJob.contactHomeAreaCode = cdjob.contactHomeAreaCode;
    aJob.contactHomeExt = cdjob.contactHomeExt;
    aJob.contactHomePhone = cdjob.contactHomePhone;
    aJob.contactID = cdjob.contactID;
    aJob.contactPagerAreaCode = cdjob.contactPagerAreaCode;
    aJob.contactPagerExt = cdjob.contactPagerExt;
    aJob.contactPagerPhone = cdjob.contactPagerPhone;
    aJob.contactPhonePref = cdjob.contactPhonePref;
    aJob.contactPhonePrefID = cdjob.contactPhonePrefID;
    aJob.contactWorkAreaCode = cdjob.contactWorkAreaCode;
    aJob.contactWorkExt = cdjob.contactWorkExt;
    aJob.contactWorkPhone = cdjob.contactWorkPhone;
    aJob.discount = cdjob.discount;
    aJob.dispatchAccepted = [cdjob.dispatchAccepted boolValue];
    aJob.dispatchID = cdjob.dispatchID;
    aJob.dispatchMessage = cdjob.dispatchMessage;
    aJob.invoiceNumber = cdjob.invoiceNumber;
    aJob.isCashedOut = [cdjob.isCashedOut boolValue];
    aJob.isCentrallyBilled = [cdjob.isCentrallyBilled boolValue];
    aJob.isDispatchAccepted = cdjob.isDispatchAccepted;
    aJob.isEnviroRequired = [cdjob.isEnviroRequired boolValue];
    aJob.jobComments = cdjob.jobComments;
    aJob.jobDate = cdjob.jobDate;
    aJob.jobDuration = [cdjob.jobDuration stringValue];//[NSNumber numberWithInt:[job.jobDuration integerValue]];
    aJob.jobEndTime = cdjob.jobEndTime;
    aJob.jobStartTime = cdjob.jobStartTime;
    aJob.jobStartTimeOriginal = cdjob.jobStartTimeOriginal;
    aJob.jobType = cdjob.jobType;
    aJob.junkCharge = cdjob.junkCharge;
    aJob.junkLocationComments = cdjob.junkLocationComments;
    aJob.nameOfLastTTUsed = cdjob.nameOfLastTTUsed;
    aJob.npsComment = cdjob.npsComment;
    aJob.npsValue = cdjob.npsValue;
    aJob.numOfJobs = cdjob.numOfJobs;
    aJob.onSiteContactAreaCode = cdjob.onSiteContactAreaCode;
    aJob.onSiteContactExt = cdjob.onSiteContactExt;
    aJob.onSiteContactID = cdjob.onSiteContactID;
    aJob.onSiteContactPhone = cdjob.onSiteContactPhone;
    aJob.onSiteContactPhonePref = cdjob.onSiteContactPhonePref;
    aJob.onSiteContactPhonePrefID = [cdjob.onSiteContactPhonePrefID stringValue];//[NSNumber numberWithInt: [job.onSiteContactPhonePrefID integerValue]];
    aJob.paymentID = cdjob.paymentID;
    aJob.pickupAddress = cdjob.pickupAddress;
    aJob.pickupCompany = cdjob.pickupCompany;
    aJob.pickupCountry = cdjob.pickupCountry;
    aJob.programDiscount = cdjob.programDiscount;
    aJob.programDiscountType = cdjob.programDiscountType;
    aJob.programNotes = cdjob.programNotes;
    aJob.promiseTime = cdjob.promiseTime;
    aJob.promoCode = cdjob.promoCode;
    aJob.subTotal = cdjob.subTotal;
    aJob.taxAmount = cdjob.taxAmount;
    aJob.taxID = cdjob.taxID;
    aJob.taxType = cdjob.taxType;
    aJob.total = [cdjob.total stringValue];//[NSNumber numberWithInt:[job.total integerValue]];
    aJob.totalSpent = cdjob.totalSpent;
    aJob.typeID = cdjob.typeID;
    aJob.zipCode = cdjob.zipCode;
    aJob.zoneColor = cdjob.zoneColor;
    aJob.zoneFontColor = cdjob.zoneFontColor;
    aJob.zoneName = cdjob.zoneName;
    
    // Look for MapPoint
    
    if(cdjob.mapPoint){
        MapPoint* mapPoint = [[MapPoint alloc] initWithName:cdjob.mapPoint.name
                                                    address:cdjob.mapPoint.address
                                                 coordinate:CLLocationCoordinate2DMake([cdjob.mapPoint.latitude doubleValue], [cdjob.mapPoint.longitude doubleValue])
                                              andResourceID:[cdjob.mapPoint.resourceTypeID intValue]];
        aJob.mapPoint = mapPoint;
    }
    return aJob;
}




@end
