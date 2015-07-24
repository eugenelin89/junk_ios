//
//  CDUser+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-30.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDUser.h"

@interface CDUser (GotJunk)

+(CDUser *) userWithID:(NSNumber*)routeID inManagedObjectContext:(NSManagedObjectContext*)context;

//+(void)assignRoutes:(NSArray *)routes toUserWithID:(NSNumber *)userID inManagedObjectContext:(NSManagedObjectContext *)context;


@end
