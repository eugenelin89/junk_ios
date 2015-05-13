//
//  MSTimeRowHeader.h
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSTimeRowHeader : UICollectionReusableView

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) NSString *time;
+(NSString *)getTime;
+ (int) minutes;
+ (int) hours;
+ (int) startTime;
+ (void) coordinate:(int)val andMinutes:(int)mins;
@end
