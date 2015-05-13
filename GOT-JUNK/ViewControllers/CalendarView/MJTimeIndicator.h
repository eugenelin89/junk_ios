//
//  MJTimeIndicator.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 3/17/2014.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJTimeIndicator : UICollectionReusableView

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) NSString *time;
+(NSString *)getTime;
+ (int) minutes;
+ (int) hours;
+ (int) startTime;
+ (void) coordinate:(int)val andMinutes:(int)mins;
@end
