//
//  APIDataConversionHelper.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-18.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIDataConversionHelper : NSObject

+(float)convertCoordinateDataForRetrieval:(int)data;
+(int)convertCoordinateDataForSaving:(float)data;

@end
