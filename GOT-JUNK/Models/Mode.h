//
//  Mode.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStoreSingleton.h"

#define ACTIVE_NOTIFICATION @"ACTIVE_NOTIFICATION"
#define STANDBY_NOTIFICATION @"STANDBY_NOTIFICATION"
#define CACHED_NOTIFICATION @"CACHED_NOTIFICATION"
#define OFFLINE_NOTIFICATION @"OFFLINE_NOTIFICATION"

typedef enum {
    ActiveModeType = 0,
    StandbyModeType,
    CachedModeType,
    OfflineModeType
} ModeType;

@protocol Mode

@property(nonatomic, readonly) ModeType modeType;

-(id<Mode>) loggedIn;
-(id<Mode>)loggedOut;
-(id<Mode>)reconnect;
-(id<Mode>)disconnect;


@end
