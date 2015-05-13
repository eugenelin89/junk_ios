//
//  MSGridlineCollectionReusableView.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSGridline.h"
#import "UIColor+ColorWithHex.h"
@implementation MSGridline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"eeeeee" andAlpha:1];
    }
    return self;
}

@end
