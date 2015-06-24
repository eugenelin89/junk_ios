//
//  CDJob+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob+GotJunk.h"
#import "CDRoute+GotJunk.h"
#import "../job.h"

@implementation CDJob (GotJunk)

+(CDJob*) jobInfo:(Job *)job inManagedObjectContext:(NSManagedObjectContext*)context
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
        
        cdjob = [matches lastObject];
    
    }else{
        // create it in DB
        cdjob = [NSEntityDescription insertNewObjectForEntityForName:@"CDJob" inManagedObjectContext:context];
        cdjob.jobID = jobID;
        cdjob.clientName = job.clientName;
        cdjob.jobDate = job.jobDate;
        
        //NSNumber *routeID =
        //job.route = [CDRoute routeWithID:routeID inManagedObjectContext:context];
        
        
    }
    
    return cdjob;
}

+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context
{
    // will need to fix this.  testing for now.
    for(NSDictionary *job in jobs){
        [self jobInfo:job inManagedObjectContext:context];
    }
}

@end
