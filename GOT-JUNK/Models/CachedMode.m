//
//  CachedMode.m
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "CachedMode.h"
#import "ActiveMode.h"
#import "OfflineMode.h"

@interface CachedMode()
@property(nonatomic, readwrite) ModeType modeType;
@end

@implementation CachedMode

-(instancetype)init
{
    self = [super init];
    NSLog(@"ENTER CACHED MODE");
    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CACHED_NOTIFICATION object:nil];
    self.modeType = CachedModeType;
    
    [DataStoreSingleton addEvent:@"EnterCachedMode"];
    
    return self;
}

-(id<Mode>)loggedIn
{
    return self;
}

-(id<Mode>)loggedOut
{
    return [[OfflineMode alloc] init];
}

-(id<Mode>)reconnect
{
    return [[ActiveMode alloc] init];
}

-(id<Mode>)disconnect
{
    return self;
}
@end
