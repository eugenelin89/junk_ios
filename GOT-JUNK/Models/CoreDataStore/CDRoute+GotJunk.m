//
//  CDRoute+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDRoute+GotJunk.h"
#import "CDJob+GotJunk.h"
#import "../Route.h"
#import "../Job.h"

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
        cdRoute.routeID = route.routeID;
        cdRoute.routeName = route.routeName;
    }else{
        // update
        NSLog(@"Route: %@ already exists", route.routeID);
        
        cdRoute = [matches lastObject];
    }

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




@end
