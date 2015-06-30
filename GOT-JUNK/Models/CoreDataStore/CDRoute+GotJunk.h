//
//  CDRoute+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDRoute.h"

@interface CDRoute (GotJunk)
+(CDRoute *) routeWithID:(NSNumber*)routeID inManagedObjectContext:(NSManagedObjectContext*)context;

+(CDRoute  *) routeWithID:(NSNumber*)routeID withName:(NSString*)routeName inManagedObjectContext:(NSManagedObjectContext *)context;

+(void) loadRoutesFromArray:(NSArray *)routes inManagedObjectContext:(NSManagedObjectContext*)context;

+(CDRoute *) getRouteWithID:(NSNumber*)routeID inManagedObjectContext:(NSManagedObjectContext*) context;

+(void)addJobs:(NSArray *)jobs toRouteWithID:(NSNumber *)jobID inManagedObjectContext:(NSManagedObjectContext*)context;

@end
