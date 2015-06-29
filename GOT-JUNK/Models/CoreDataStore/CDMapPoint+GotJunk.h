//
//  CDMapPoint+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-29.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDMapPoint.h"
#import "../MapPoint.h"
#import "../Job.h"

@interface CDMapPoint (GotJunk)
+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint withCDJob:(CDJob*)job inManagedObjectContext:(NSManagedObjectContext*)context;
+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint withJob:(Job*)job inManagedObjectContext:(NSManagedObjectContext*)context;
@end
