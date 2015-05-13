//
//  NSNull+NSNull_JSON_m.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 5/5/2014.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import "NSNull+JSON.h"
#import <CoreGraphics/CoreGraphics.h>

@interface NSNull (JSON)
@end

@implementation NSNull (JSON)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (CGFloat)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end