//
//  LoadTypeSize.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-20.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadTypeSize : NSObject

@property int loadTypeSizeID;
@property (nonatomic, strong) NSString *loadTypeSize;
@property int loadTypeID;
@property float percentOfTruck;

- (id)init:(int)loadTypeSizeID withLoadTypeID:(int)loadTypeID withLoadTypeSize:(NSString *)loadTypeSize withPercent:(float)percentOfTruck;

@end
