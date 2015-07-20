//
//  DateHelper.h
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 2/4/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject

+ (NSDate *)now;
+ (NSDate *)tomorrow:(NSDate *)currentDate;
+ (NSDate *)yesterday:(NSDate *)currentDate;
+ (NSString *)nowString;
+ (NSString *)dateToApiString:(NSDate *)date;
+ (NSString *)dateToJobListString:(NSDate *)date;
+ (NSDate*)dateFromMinutesSinceMidnight:(NSInteger)minutesSinceMidnight andDayAsString:(NSString*)day;
+ (int)secondsSinceMidnight;
+ (NSDate *)midnightToday;
+(NSDate*)dayStart:(NSDate *)today;
+(NSDate*)dayEnd:(NSDate *)today;
@end
