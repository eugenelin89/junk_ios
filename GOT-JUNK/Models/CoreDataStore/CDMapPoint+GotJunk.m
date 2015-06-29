//
//  CDMapPoint+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-29.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDMapPoint+GotJunk.h"
#import "CDJob.h"
#import "CDJob+GotJunk.h"

@implementation CDMapPoint (GotJunk)
+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint withCDJob:(CDJob*)job inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDMapPoint * cdmapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"CDMapPoint" inManagedObjectContext:context];
    
    job.mapPoint = cdmapPoint;
    
    cdmapPoint.resourceTypeID = [NSNumber numberWithInt: mapPoint.resourceTypeID];
    cdmapPoint.type = mapPoint.type;
    cdmapPoint.name = mapPoint.name;
    cdmapPoint.address = mapPoint.address;
    cdmapPoint.latitude = [NSNumber numberWithDouble: mapPoint.coordinate.latitude];
    cdmapPoint.longitude = [NSNumber numberWithDouble:mapPoint.coordinate.longitude];
    return cdmapPoint;
}

+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint withJob:(Job*)job inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDMapPoint *cdMapPoint = nil;
    
    NSNumber *jobID = job.jobID;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDJob"];
    request.predicate = [NSPredicate predicateWithFormat:@"jobID = %@", jobID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    CDJob *cdjob = nil;
    
    if(!matches || error || [matches count] > 1){
        // handle error
    }else if([matches count]){
        
        NSLog(@"Adding CDMapPoint on existing CDJob: %@", job.jobID);
        cdjob = [matches lastObject];
        
    }else{
        // create it in DB
        NSLog(@"Adding CDMapPoint.  CDJob does not exist.  Create.");
        cdjob = [CDJob job:job inManagedObjectContext:context];
    }
    
    cdMapPoint = [CDMapPoint mapPoint:mapPoint withCDJob: cdjob inManagedObjectContext: context];
    return cdMapPoint;
}

@end
