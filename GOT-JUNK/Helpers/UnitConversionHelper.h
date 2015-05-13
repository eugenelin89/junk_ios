//
//  UnitConversionHelper.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnitConversionHelper : NSObject

+ (float)convertWeight:(float)weight fromType:(int)fromTypeID toType:(int)toTypeID;


@end
