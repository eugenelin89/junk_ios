//
//  CDJob+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob.h"
#import "../Job.h"

@interface CDJob (GotJunk)

/*
 * Loading a Job object into Core Data
 */
+(CDJob*) job:(Job *)job inManagedObjectContext:(NSManagedObjectContext*)context;

/*
 * Loading an array of Job objects into Core Data.
 */
+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context;

+(NSArray *)jobsForDate:(NSDate*)date forRoute:(NSNumber*)routeID InManagedContext:(NSManagedObjectContext*)context;

+(void)deleteJobsForDate:(NSDate*)date forRoute:(NSNumber*)routeID inManagedContext:(NSManagedObjectContext*)context;

+(void)deleteJobsForDate:(NSDate*)fromDate toDate:(NSDate*)toDate forRoute:(NSNumber*)routeID inManagedContext:(NSManagedObjectContext*)context;

+(Job *) toJobWithCDJob:(CDJob *)cdjob;

@end
