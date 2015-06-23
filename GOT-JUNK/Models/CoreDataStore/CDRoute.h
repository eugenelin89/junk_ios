//
//  CDRoute.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDJob;

@interface CDRoute : NSManagedObject

@property (nonatomic, retain) NSNumber * routeID;
@property (nonatomic, retain) NSString * routeName;
@property (nonatomic, retain) NSSet *jobs;
@end

@interface CDRoute (CoreDataGeneratedAccessors)

- (void)addJobsObject:(CDJob *)value;
- (void)removeJobsObject:(CDJob *)value;
- (void)addJobs:(NSSet *)values;
- (void)removeJobs:(NSSet *)values;

@end
