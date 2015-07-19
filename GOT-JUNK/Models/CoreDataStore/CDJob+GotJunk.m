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
        cdjob.jobID = jobID;
    }
    
    cdjob.routeID = job.routeID;
    cdjob.clientName = job.clientName;
    cdjob.jobDate = job.jobDate;
    cdjob.callAheadStatus = job.callAheadStatus;
    cdjob.callAheadTime = job.callAheadTime;
    cdjob.clientCompany = job.clientCompany;
    cdjob.clientEmail = job.clientEmail;
    cdjob.clientTypeID = job.clientTypeID;
    cdjob.comments = job.comments;
    cdjob.contactCell = job.contactCell;
    cdjob.contactCellAreaCode = job.contactCellAreaCode;
    cdjob.contactCellExt = job.contactCellExt;
    cdjob.contactFax = job.contactFax;
    cdjob.contactFaxAreaCode = job.contactFaxAreaCode;
    cdjob.contactFaxExt = job.contactFaxExt;
    cdjob.contactHomeAreaCode = job.contactHomeAreaCode;
    cdjob.contactHomeExt = job.contactHomeExt;
    cdjob.contactHomePhone = job.contactHomePhone;
    cdjob.contactID = job.contactID;
    cdjob.contactPagerAreaCode = job.contactPagerAreaCode;
    cdjob.contactPagerExt = job.contactPagerExt;
    cdjob.contactPagerPhone = job.contactPagerPhone;
    cdjob.contactPhonePref = job.contactPhonePref;
    cdjob.contactPhonePrefID = job.contactPhonePrefID;
    cdjob.contactWorkAreaCode = job.contactWorkAreaCode;
    cdjob.contactWorkExt = job.contactWorkExt;
    cdjob.contactWorkPhone = job.contactWorkPhone;
    cdjob.discount = job.discount;
    cdjob.dispatchAccepted = [NSNumber numberWithBool:job.dispatchAccepted];
    cdjob.dispatchID = job.dispatchID;
    cdjob.dispatchMessage = job.dispatchMessage;
    cdjob.invoiceNumber = job.invoiceNumber;
    cdjob.isCashedOut = [NSNumber numberWithBool:job.isCashedOut];
    cdjob.isCentrallyBilled = [NSNumber numberWithBool:job.isCentrallyBilled];
    cdjob.isDispatchAccepted = job.isDispatchAccepted;
    cdjob.isEnviroRequired = [NSNumber numberWithBool:job.isEnviroRequired];
    cdjob.jobComments = job.jobComments;
    cdjob.jobDate = job.jobDate;
    cdjob.jobDuration = [NSNumber numberWithInt:[job.jobDuration integerValue]];
    cdjob.jobEndTime = job.jobEndTime;
    cdjob.jobStartTime = job.jobStartTime;
    cdjob.jobStartTimeOriginal = job.jobStartTimeOriginal;
    cdjob.jobType = job.jobType;
    cdjob.junkCharge = job.junkCharge;
    cdjob.junkLocationComments = job.junkLocationComments;
    cdjob.nameOfLastTTUsed = job.nameOfLastTTUsed;
    cdjob.npsComment = job.npsComment;
    cdjob.npsValue = job.npsValue;
    cdjob.numOfJobs = job.numOfJobs;
    cdjob.onSiteContactAreaCode = job.onSiteContactAreaCode;
    cdjob.onSiteContactExt = job.onSiteContactExt;
    cdjob.onSiteContactID = job.onSiteContactID;
    cdjob.onSiteContactPhone = job.onSiteContactPhone;
    cdjob.onSiteContactPhonePref = job.onSiteContactPhonePref;
    cdjob.onSiteContactPhonePrefID = [NSNumber numberWithInt: [job.onSiteContactPhonePrefID integerValue]];
    cdjob.paymentID = job.paymentID;
    cdjob.pickupAddress = job.pickupAddress;
    cdjob.pickupCompany = job.pickupCompany;
    cdjob.pickupCountry = job.pickupCountry;
    cdjob.programDiscount = job.programDiscount;
    cdjob.programDiscountType = job.programDiscountType;
    cdjob.programNotes = job.programNotes;
    cdjob.promiseTime = job.promiseTime;
    cdjob.promoCode = job.promoCode;
    cdjob.subTotal = job.subTotal;
    cdjob.taxAmount = job.taxAmount;
    cdjob.taxID = job.taxID;
    cdjob.taxType = job.taxType;
    cdjob.total = [NSNumber numberWithInt:[job.total integerValue]];
    cdjob.totalSpent = job.totalSpent;
    cdjob.typeID = job.typeID;
    cdjob.zipCode = job.zipCode;
    cdjob.zoneColor = job.zoneColor;
    cdjob.zoneFontColor = job.zoneFontColor;
    cdjob.zoneName = job.zoneName;

    
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

+(NSArray *)jobsForDate:(NSDate*)date forRoute:(NSNumber*)routeID InManagedContext:(NSManagedObjectContext*)context
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    [comp setMinute:0];
    [comp setHour:0];
    NSDate *todayStart = [cal dateFromComponents:comp];
    [comp setMinute:59];
    [comp setHour:23];
    NSDate *todayEnd = [cal dateFromComponents:comp];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobDate >= %@ AND jobDate <= %@ AND routeID = %@", todayStart, todayEnd, routeID];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSMutableArray *tempArray;
    
    if(!matches || error){
        // Handle Error
        NSLog(@"ERROR retrieving jobs from core data: %@", error);
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
