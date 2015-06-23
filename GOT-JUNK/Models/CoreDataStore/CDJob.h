//
//  CDJob.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-23.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDRoute;

@interface CDJob : NSManagedObject

@property (nonatomic, retain) NSNumber * jobID;
@property (nonatomic, retain) NSDate * jobDate;
@property (nonatomic, retain) NSString * clientName;
@property (nonatomic, retain) CDRoute *route;

@end
