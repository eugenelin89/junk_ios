//
//  CDMapPoint+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-29.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDMapPoint.h"
#import "../MapPoint.h"

@interface CDMapPoint (GotJunk)
+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint WithCDJob:(CDJob*)job inManagedObjectContext:(NSManagedObjectContext*)context;
@end
