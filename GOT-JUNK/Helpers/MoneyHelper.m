//
//  MoneyHelper.m
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 2/27/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MoneyHelper.h"

@implementation MoneyHelper

# pragma mark - Parsing

+ (NSInteger)moneyStringToCents:(NSString *)moneyString
{
    int dollars = 0;
    int cents = 0;

    if ([moneyString rangeOfString:@"."].location == NSNotFound) {
        dollars = [moneyString integerValue];
    } else {
        NSArray *components = [moneyString componentsSeparatedByString: @"."];

        dollars = [[components objectAtIndex: 0] integerValue];
        cents = [[components objectAtIndex: 1] integerValue];
    }

    return (dollars * 100) + cents;
}

@end
