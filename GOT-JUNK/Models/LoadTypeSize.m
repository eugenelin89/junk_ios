//
//  LoadTypeSize.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-20.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LoadTypeSize.h"

@implementation LoadTypeSize

- (id)init:(int)loadTypeSizeID withLoadTypeID:(int)loadTypeID withLoadTypeSize:(NSString *)loadTypeSize withPercent:(float)percentOfTruck
{
    self.loadTypeID = loadTypeID;
    self.loadTypeSizeID = loadTypeSizeID;
    self.loadTypeSize = loadTypeSize;
    self.percentOfTruck = percentOfTruck;
    return self;
}

@end
