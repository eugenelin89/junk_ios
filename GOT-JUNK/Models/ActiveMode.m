//
//  ActiveMode.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "ActiveMode.h"
#import "StandbyMode.h"
#import "CachedMode.h"

@implementation ActiveMode

-(instancetype)init
{
    [super init];
    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVE_NOTIFICATION object:nil];
}

-(id<Mode>)loggedIn
{
    return self;
}

-(id<Mode>)loggedOut
{
    return [[StandbyMode alloc] init];
}

-(id<Mode>)reconnect
{
    return self;
}

-(id<Mode>)disconnect
{
    return [[CachedMode alloc] int];
}



@end
