//
//  Job.m
//  GOT-JUNK
//
//  Created by epau on 1/31/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "Job.h"

@implementation Job

- (BOOL)isBookoff
{
  return [self.jobType integerValue] == JobTypeBookOff;
}

- (void)parseOutLocationComments
{
    NSRange ran = [self.comments rangeOfString:@"JUNK LOCATION"];
    if( ran.length == 0 )
    {
        return;
    }
    
    self.junkLocationComments = [self.comments substringFromIndex:ran.location];
    self.jobComments = [self.comments stringByPaddingToLength:ran.location withString:@"" startingAtIndex:0];
}

- (void)appendCommentsAndJunkLocation:(NSString*)comments
{
    self.jobComments = [NSString stringWithFormat:@"%@\n%@", self.jobComments, comments];
    self.comments = [NSString stringWithFormat:@"%@\n%@", self.jobComments, self.junkLocationComments];
}

+ (void)updateValuesOfJob:(Job *)oldJob withNewJob:(Job *)newJob
{
    if ([oldJob.jobID isEqual: newJob.jobID])
    {
        oldJob.callAheadTime = newJob.callAheadTime;
        oldJob.callAheadStatus = newJob.callAheadStatus;
        oldJob.clientCompany = newJob.clientCompany;
        oldJob.clientName = newJob.clientName;
        oldJob.clientEmail = newJob.clientEmail;
        oldJob.comments = newJob.comments;
        oldJob.jobDate = newJob.jobDate;
        oldJob.jobDateAsString = newJob.jobDateAsString;
        oldJob.jobDuration = newJob.jobDuration;
        oldJob.jobStartTime = newJob.jobStartTime;
        oldJob.jobEndTime = newJob.jobEndTime;
        oldJob.pickupAddress = newJob.pickupAddress;
        oldJob.taxID = newJob.taxID;
        oldJob.zipCode = newJob.zipCode;
        oldJob.discount = newJob.discount;
        oldJob.invoiceNumber = newJob.invoiceNumber;
        oldJob.paymentID = newJob.paymentID;
        oldJob.subTotal = newJob.subTotal;
        oldJob.dispatchMessage = newJob.dispatchMessage;
        oldJob.dispatchAccepted = newJob.dispatchAccepted;
        oldJob.typeID = newJob.typeID;
        oldJob.jobType = newJob.jobType;
        oldJob.dispatchID = newJob.dispatchID;
        oldJob.isDispatchAccepted = newJob.isDispatchAccepted;
    }
}

- (BOOL)isDispatchJob
{
    return [self.dispatchID intValue] != 0;
}

- (BOOL)isDispatchJobAccepted
{
    return [self.dispatchID intValue] != 0 && [self.isDispatchAccepted intValue] == 1;
}

@end
