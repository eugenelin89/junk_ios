//
//  UnitConversionHelper.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "UnitConversionHelper.h"

@implementation UnitConversionHelper

+ (float)convertWeight:(float)weight fromType:(int)fromTypeID toType:(int)toTypeID
{
    float conversionToPounds = [self getConversionRateInPounds:fromTypeID];
    float conversionToNewWeightType = [self getConversionRateInPounds:toTypeID];
    
    
    // convert to pounds
    float weightInPounds = weight * conversionToPounds;
    
    // convert from pounds to the new weight type
    return  weightInPounds / conversionToNewWeightType;
    
}


+ (float)getConversionRateInPounds:(int)weightTypeID
{
    switch(weightTypeID){
        case 1: return 1;
        case 2: return 2.20462262;
        default: return 2000;
    }
    
}

@end
