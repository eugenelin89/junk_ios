//
//  Enviro.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-07.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enviro : NSObject

@property int environmentID;
@property int environmentCategorizationID;
@property (nonatomic, strong) NSString * loadType;
@property int loadTypeID;

@property int numberOfTrucks;
@property (nonatomic, strong) NSString * loadTypeSize;
@property int loadTypeSizeID;

@property int junkTypeID;
@property (nonatomic, strong) NSString * junkType;

@property int destinationID;
@property (nonatomic, strong) NSString * destination;

@property float percentOfJob;
//@property float diversion; // retire this field

//@property float weight; // retire this field
@property int weightTypeID;
@property (nonatomic, strong) NSString * weightType;

@property float calculatedWeight;
@property float actualWeight;
@property float userDiversion;
@property float defaultDiversion;
@property bool isSortable;
@property int jobID;
@property float calculatedLoadSize;


// we use this to help calculate the % of the overall job that this particular breakdown comprises.
@property float totalTruckSize;

@end
