//
//  CDUser.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-30.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDRoute;

@interface CDUser : NSManagedObject

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *assignedRoutes;
@end

@interface CDUser (CoreDataGeneratedAccessors)

- (void)addAssignedRoutesObject:(CDRoute *)value;
- (void)removeAssignedRoutesObject:(CDRoute *)value;
- (void)addAssignedRoutes:(NSSet *)values;
- (void)removeAssignedRoutes:(NSSet *)values;

@end
