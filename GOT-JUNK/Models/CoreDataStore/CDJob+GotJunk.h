//
//  CDJob+GotJunk.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CDJob.h"

@interface CDJob (GotJunk)

+(CDJob*) jobInfo:(NSDictionary *)jobDictionary inManagedObjectContext:(NSManagedObjectContext*)context;

+(void) loadJobsFromArray:(NSArray *)jobs inManagedObjectContext:(NSManagedObjectContext*)context;

@end
