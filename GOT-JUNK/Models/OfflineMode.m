//
//  OfflineMode.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "OfflineMode.h"
#import "CachedMode.h"
#import "StandbyMode.h"

@interface OfflineMode()
@property(nonatomic, readwrite) ModeType modeType;
@end

@implementation OfflineMode

-(instancetype)init
{
    self = [super init];
    NSLog(@"ENTER OFFLINE MODE");

    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:OFFLINE_NOTIFICATION object:nil];
    self.modeType = OfflineModeType;
    return self;
}

-(id<Mode>)loggedIn
{
    // logged in via Offline Key
    return [[CachedMode alloc] init];
}

-(id<Mode>)loggedOut
{
    return self;
}

-(id<Mode>)reconnect
{
    return [[StandbyMode alloc] init];
}

-(id<Mode>)disconnect
{
    return self;
}
@end
