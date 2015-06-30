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

@end
