//
//  CDRoute+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDRoute+GotJunk.h"
#import "../Route.h"

@implementation CDRoute (GotJunk)

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
        CDRoute*  cdroute = [CDRoute routeWithID:route.routeID inManagedObjectContext:context];
        cdroute.routeName = route.routeName;
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
