//
//  CDJob+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob+GotJunk.h"
#import "CDRoute+GotJunk.h"

@implementation CDJob (GotJunk)

+(CDJob*) jobInfo:(NSDictionary *)jobDictionary inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDJob *job = nil;
    
    NSNumber *jobID = jobDictionary[@"jobID"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobID = %@", jobID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || error || [matches count] > 1){
        // handle error
    }else if([matches count]){
        // Update Job
        
        job = [matches lastObject];
    
    }else{
        // create it in DB
        job = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:context];
        job.jobID = jobID;
        job.clientName = jobDictionary[@"clientName"];
        job.jobDate = jobDictionary[@"jobDate"];
        
        NSNumber *routeID = jobDictionary[@"routeID"];
        job.route = [CDRoute routeWithID:routeID inManagedObjectContext:context];
        
        
    }
    
    return job;
}

+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context
{
}

@end
