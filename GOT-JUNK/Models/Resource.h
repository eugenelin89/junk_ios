//
//  Resource.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-11.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MapPoint;

@interface Resource : NSObject

@property int resourceID;
@property (nonatomic, strong) NSString * resourceName;
@property int resourceTypeID;
@property (nonatomic, strong) NSString * resourceType;
@property float latitude;
@property float longitude;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) MapPoint *mapPoint;

- (BOOL)isEqual:(id)object;

- (NSString *)getAddress;

@end
