//
//  MJTimeIndicator.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 3/17/2014.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import "MJTimeIndicator.h"
#import "UIColor+ColorWithHex.h"
@implementation MJTimeIndicator


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //old way
        
                self.backgroundColor = [UIColor clearColor];
                self.title = [UILabel new];
                self.title.backgroundColor = [UIColor clearColor];
                self.title.font = [UIFont systemFontOfSize:12.0];
                self.title.textColor = [UIColor colorWithHexString:@"918c8c" andAlpha:1];
                self.title.shadowColor = [UIColor whiteColor];
                self.title.text = @"8:00";
                int i = self.frame.origin.y / 80;
                int j = i/2;
                int k = i%2;
                j = startTime + j;
                if (MJTimeIndicator.minutes == 0)
               {
                if (k == 1)
                    self.title.text = [NSString stringWithFormat:@"%d:%d0", j,3];
                else
                    self.title.text = [NSString stringWithFormat:@"%d:%d0", j,MJTimeIndicator.minutes];
                }
                else
                {
                    if (k == 1)
                        self.title.text = [NSString stringWithFormat:@"%d:%d0", j+1,0];
                    else
                        self.title.text = [NSString stringWithFormat:@"%d:%d", j,MJTimeIndicator.minutes];
                }
                //NSLog(@"time is %@", self.title.text);
            //    self.title.shadowOffset = CGSizeMake(0.0, 1.0);
     //   self.title.text = [NSString stringWithFormat:@"%d", i];
                [self addSubview:self.title];
        
//        self.backgroundColor = [UIColor clearColor];
//        self.title = [UILabel new];
//        self.title.backgroundColor = [UIColor clearColor];
//        self.title.font = [UIFont systemFontOfSize:12.0];
//        self.title.textColor = [UIColor colorWithHexString:@"918c8c" andAlpha:1];
//        self.title.shadowColor = [UIColor whiteColor];
//        self.title.text = @"8:00";
//        CGRect rect1 = [self  bounds];
//        int i = self.frame.origin.y / 80;
//        
//        int j = i/2;
//        int k = i%2;
//        j = startTime + j;
//        self.title.text = [NSString stringWithFormat:@"%d", i];
//        NSLog(@"time is %@", self.title.text);
//        
//        self.title.text = @"8:00";
//        self.title.shadowOffset = CGSizeMake(0.0, 1.0);
//        [self addSubview:self.title];
    }
    return self;
}

+(NSString *)getTime
{
    
    if (MJTimeIndicator.minutes == 0)
        return [NSString stringWithFormat:@"%d:%d0", MJTimeIndicator.hours,MJTimeIndicator.minutes];
    else
        return [NSString stringWithFormat:@"%d:%d", MJTimeIndicator.hours,MJTimeIndicator.minutes];
    
}


static int minutes;
+ (int) minutes
{ @synchronized(self) { return minutes; } }
+ (void) setMinutes:(int)val
{ @synchronized(self) { minutes = val; } }
static int hours;
+ (int) hours
{ @synchronized(self) { return hours; } }
+ (void) setHours:(int)val
{ @synchronized(self) { hours = val; } }
static int startTime;
+ (int) startTime
{ @synchronized(self) { return startTime; } }
+ (void) startTime:(int)val
{ @synchronized(self) { startTime = val; } }
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIEdgeInsets margin = UIEdgeInsetsMake(5.0, 8.0, 0.0, 8.0);
    
    [self.title sizeToFit];
    CGRect titleFrame = self.title.frame;
    titleFrame.origin.x = nearbyintf(CGRectGetWidth(self.frame) - CGRectGetWidth(titleFrame)) - margin.right;
    titleFrame.origin.x += 5;
    titleFrame.origin.y = nearbyintf((CGRectGetHeight(self.frame) / 2.0) - (CGRectGetHeight(titleFrame) / 2.0));
    titleFrame.size.width = 40;
    self.title.textAlignment = NSTextAlignmentLeft;
    self.title.frame = titleFrame;
    //self.version
    self.title.text = [NSString stringWithFormat:@"%f", self.frame.origin.y];
    int i = self.frame.origin.y / 80;
    int j = i/2;
    int k = i%2;
    j = startTime + j;
    if (MJTimeIndicator.minutes == 0)
    {
        if (k == 1)
            self.title.text = [NSString stringWithFormat:@"%d:%d0", j,3];
        else
            self.title.text = [NSString stringWithFormat:@"%d:%d0", j,MJTimeIndicator.minutes];
    }
    else
    {
        if (k == 1)
            self.title.text = [NSString stringWithFormat:@"%d:%d0", j+1,0];
        else
            self.title.text = [NSString stringWithFormat:@"%d:%d", j,MJTimeIndicator.minutes];
    }
    // self.title.text = [MSTimeRowHeader getTime];
}

#pragma mark - MSTimeRowHeader
+ (void) coordinate:(int)val andMinutes:(int)mins
{
    startTime = val;
    minutes = mins;
    
}
- (void)setTime:(NSString *)time
{
    // _time = time;
  //  self.title.text = @"Jello";
    // NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // dateFormatter.dateFormat = @"h a";
    //  self.title.text =@"Yo";// [[dateFormatter stringFromDate:time] uppercaseString];
    [self setNeedsLayout];
}

@end
