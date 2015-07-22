//
//  CDUser+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-30.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDUser+GotJunk.h"
#import "CDRoute+GotJunk.h"
#import "../Route.h"

@implementation CDUser (GotJunk)

+(CDUser *) userWithID:(NSNumber*)userID inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDUser *cdUser = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"userID = %@", userID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count]>1){
        // handle error
        NSLog(@"Error querying route.");
        
    }else if(![matches count]){
        // insert
        NSLog(@"Adding new route: %@", userID);
        
        cdUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser" inManagedObjectContext:context];
        cdUser.userID = userID;
    }else{
        // update
        NSLog(@"Route: %@ already exists", userID);
        cdUser = [matches lastObject];
    }
    
    return cdUser;
}

/*
+(void)assignRoutes:(NSArray *)routes toUserWithID:(NSNumber *)userID inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDUser *cdUser = [CDUser userWithID: userID inManagedObjectContext:context];
    
    [cdUser removeAssignedRoutes:cdUser.assignedRoutes];
    
    if(cdUser){
        for(Route *route in routes){
            CDRoute *aRoute = [CDRoute route:route inManagedObjectContext:context];
            [cdUser addAssignedRoutesObject:aRoute];
        }
    }

}
*/


@end
