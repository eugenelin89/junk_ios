//
//  CDJob+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob.h"
#import "../Job.h"

@interface CDJob (GotJunk)

+(CDJob*) job:(Job *)job inManagedObjectContext:(NSManagedObjectContext*)context;

+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context;

@end
