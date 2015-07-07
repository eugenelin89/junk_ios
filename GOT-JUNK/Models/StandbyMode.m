//
//  StandbyMode.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "StandbyMode.h"
#import "ActiveMode.h"
#import "OfflineMode.h"

@interface StandbyMode()
@property(nonatomic, readonly) ModeType modeType;
@end

@implementation StandbyMode

-(instancetype)init
{
    [super init];
    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:STANDBY_NOTIFICATION object:nil];
    self.modeType = StandbyModeType;
}

-(id<Mode>)loggedIn
{
    return [[ActiveMode alloc] init];
}

-(id<Mode>)loggedOut
{
    return self;
}

-(id<Mode>)reconnect
{
    return self;
}

-(id<Mode>)disconnect
{
    return [[OfflineMode alloc] init];
}
@end
