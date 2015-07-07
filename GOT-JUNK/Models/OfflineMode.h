//
//  OfflineMode.h
//  GOT-JUNK
//
//  Created by Eugene Lin on 2015-07-06.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mode.h"

@interface OfflineMode : NSObject <Mode>
@property(nonatomic, readonly) ModeType modeType;
@end
