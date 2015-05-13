//
//  APIDataConversionHelper.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-18.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "APIDataConversionHelper.h"

@implementation APIDataConversionHelper

static const int COORDINATE_CONVERSION_FACTOR = 100000;

+(float)convertCoordinateDataForRetrieval:(int)data
{
    return ((float)(data)) / COORDINATE_CONVERSION_FACTOR;
}
+(int)convertCoordinateDataForSaving:(float)data
{
    return data * COORDINATE_CONVERSION_FACTOR;
}

@end
