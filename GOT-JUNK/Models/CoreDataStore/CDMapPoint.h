//
//  CDMapPoint.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-06-29.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDJob;

@interface CDMapPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * resourceTypeID;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) CDJob *job;

@end
