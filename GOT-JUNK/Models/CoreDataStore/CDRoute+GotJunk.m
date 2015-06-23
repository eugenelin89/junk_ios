//
//  CDRoute+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDRoute+GotJunk.h"

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
    }else if(![matches count]){
        // insert
        route = [NSEntityDescription insertNewObjectForEntityForName:@"CDRoute" inManagedObjectContext:context];
    }else{
        // update
        route = [matches lastObject];
    }
    
    
    return route;
}

@end
