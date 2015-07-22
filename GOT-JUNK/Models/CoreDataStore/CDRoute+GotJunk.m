//
//  CDRoute+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDRoute+GotJunk.h"
#import "CDJob+GotJunk.h"
#import "../Job.h"
#import "../Route.h"
#import "../DateHelper.h"

@implementation CDRoute (GotJunk)


+(CDRoute *) route:(Route*)route inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDRoute *cdRoute = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDRoute"];
    request.predicate = [NSPredicate predicateWithFormat:@"routeID = %@", route.routeID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count]>1){
        // handle error
        NSLog(@"Error querying route.");
        
    }else if(![matches count]){
        // insert
        NSLog(@"Adding new route: %@", route.routeID);
        cdRoute = [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute" inManagedObjectContext:context];

    }else{
        // update
        NSLog(@"Route: %@ already exists", route.routeID);
        cdRoute = [matches lastObject];
    }
    cdRoute.routeID = route.routeID;
    cdRoute.routeName = route.routeName;

    return cdRoute;
}

+(CDRoute *) routeWithID:(NSNumber*)routeID inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDRoute *route = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDRoute"];
    request.predicate = [NSPredicate predicateWithFormat:@"routeID = %@", routeID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count]>1){
        // handle error
        NSLog(@"Error querying route.");

    }else if(![matches count]){
        // insert
        NSLog(@"Adding new route: %@", routeID);

        route = [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute" inManagedObjectContext:context];
        route.routeID = routeID;
    }else{
        // update
        NSLog(@"Route: %@ already exists", routeID);

        route = [matches lastObject];
    }
    
    return route;
}

+(CDRoute  *) routeWithID:(NSNumber*)routeID withName:(NSString*)routeName inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDRoute *cdRoute = [CDRoute routeWithID:routeID inManagedObjectContext:context];
    cdRoute.routeName = routeName;
    return cdRoute;
}

+(void) loadRoutesFromArray:(NSArray *)routes inManagedObjectContext:(NSManagedObjectContext*)context
{
    for(Route* route in routes){
        [CDRoute route:route inManagedObjectContext:context];
    }
}

+(void)addJobs:(NSArray *)jobs toRouteWithID:(NSNumber *)jobID inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDRoute *cdRoute = [CDRoute getRouteWithID:jobID inManagedObjectContext:context];
    if(cdRoute){
        for(Job *job in jobs){
            [cdRoute addJobsObject:[CDJob job:job inManagedObjectContext:context]];
        }
    }
}



+(CDRoute *) getRouteWithID:(NSNumber*)routeID inManagedObjectContext:(NSManagedObjectContext*) context
{
    CDRoute *route = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDRoute"];
    request.predicate = [NSPredicate predicateWithFormat:@"routeID = %@", routeID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count]>1){
        // handle error
    }else if([matches count]){
        route = [matches lastObject];
    }
    
    return route;
}

+(NSArray *)routesInManagedObjectContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDRoute"];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSMutableArray *tempArray;
    if(!matches || error){
        // handle error
    }else{
        tempArray = [[NSMutableArray alloc] initWithCapacity:matches.count];
        for(CDRoute* cdroute in matches){
            Route *aRoute = [[Route alloc] init];
            aRoute.routeID = cdroute.routeID;
            aRoute.routeName = cdroute.routeName;
            //aRoute.jobsInRoute = [NSNumber numberWithInt: cdroute.jobs.count];
            
            int jobCount = 0;
            for(CDJob *job in cdroute.jobs){
                if([DateHelper isCurrentDay:job.jobDate]){
                    jobCount++;
                }
            }
            aRoute.jobsInRoute = [NSNumber numberWithInt: jobCount];

            
            [tempArray addObject:aRoute];
        }
    }
    return tempArray;
}





@end
