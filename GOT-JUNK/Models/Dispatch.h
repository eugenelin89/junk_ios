//
//  Dispatch.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-11-27.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dispatch : NSObject
@property int dispatchID;
@property int appointmentID;
@property int routeID;
@property int jobID;
@property (nonatomic, strong) NSString * dispatchMode;
@property (nonatomic, strong) NSString * promiseTime;
@property (nonatomic, strong) NSDate * receiveDate;
@property (nonatomic, strong) NSString * receiveMode;
@end
