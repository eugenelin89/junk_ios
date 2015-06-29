//
//  CDMapPoint+GotJunk.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-29.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDMapPoint+GotJunk.h"
#import "CDJob.h"

@implementation CDMapPoint (GotJunk)
+(CDMapPoint *) mapPoint:(MapPoint *)mapPoint WithCDJob:(CDJob*)job inManagedObjectContext:(NSManagedObjectContext*)context
{
    CDMapPoint * cdmapPoint = [NSEntityDescription insertNewObjectForEntityForName:@"CDMapPoint" inManagedObjectContext:context];
    cdmapPoint.job = job;
    cdmapPoint.resourceTypeID = [NSNumber numberWithInt: mapPoint.resourceTypeID];
    cdmapPoint.type = mapPoint.type;
    cdmapPoint.name = mapPoint.name;
    cdmapPoint.address = mapPoint.address;
    cdmapPoint.latitude = [NSNumber numberWithDouble: mapPoint.coordinate.latitude];
    cdmapPoint.longitude = [NSNumber numberWithDouble:mapPoint.coordinate.longitude];
    return cdmapPoint;
}
@end
