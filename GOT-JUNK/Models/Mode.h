//
//  Mode.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Mode
-(id<Mode>) loggedIn;
-(id<Mode>)loggedOut;
-(id<Mode>)reconnect;
-(id<Mode>)disconnect;

@end
