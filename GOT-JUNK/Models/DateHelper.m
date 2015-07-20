//
//  DateHelper.m
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 2/4/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "DateHelper.h"
#import "Globals.h"
#import "DataStoreSingleton.h"

@implementation DateHelper

+ (NSDate *)now
{
    return [NSDate date];
}

+ (NSString *)nowString
{
    return [DateHelper dateToApiString: [DateHelper now]];
}

+ (NSDate *)tomorrow:(NSDate *)currentDate
{
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
  [offsetComponents setDay:1];
  NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:currentDate options:0];
  return nextDate;
}

+ (NSDate *)yesterday:(NSDate *)currentDate
{
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
  [offsetComponents setDay:-1];
  NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:currentDate options:0];
  return nextDate;
}

+ (NSString *)dateToApiString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    [dateFormatter setDateFormat:@"yyyyMMdd"];

    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSLog(@"formattedDateString: %@", formattedDateString);

    return formattedDateString;
}

+ (NSString *)dateToJobListString:(NSDate *)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  //[dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
  [dateFormatter setDateFormat:@"MMM dd yyyy"];
  
  NSString *formattedDateString = [dateFormatter stringFromDate:date];
  NSLog(@"formattedDateString: %@", formattedDateString);
  
  return formattedDateString;
}

+ (NSDate*)dateFromMinutesSinceMidnight:(NSInteger)minutesSinceMidnight andDayAsString:(NSString *)day
{  
  NSInteger hours = minutesSinceMidnight/60;
  NSInteger minutes = minutesSinceMidnight%60;
  
  NSLog(@"hours: %d, mins: %d", hours, minutes);
  
  NSString *time = nil;
  
  if (minutes < 10)
  {
    time = [NSString stringWithFormat:@"%d:0%d", hours, minutes];
  }
  else
  {
    time = [NSString stringWithFormat:@"%d:%d", hours, minutes];
  }
  
  NSLog(@"day: %@, time: %@", day, time);
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyyMMdd-HH:mm"];
  NSString *dateString = [NSString stringWithFormat:@"%@-%@", day, time];
  NSDate *date = [dateFormatter dateFromString:dateString];
  
  NSLog(@"date before shifting: %@", date);
  
  return date;
  
  //NSDate *date = [NSDate date];
  //NSDate *date = [NSDate dateWithTimeIntervalSince1970:1361361600];
  //NSTimeZone *newYork = [NSTimeZone timeZoneWithName:@"America/New_York"];
  //return [date dateByAddingTimeInterval:[newYork secondsFromGMT]];
}

+ (int)secondsSinceMidnight
{
    NSDate *midnight = [self midnightToday];
    return abs([midnight timeIntervalSinceNow]);
}

+ (NSDate *)midnightToday
{
    NSDate *now = [NSDate date];
    NSDate *midnight = [NSDate date];
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *todayComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    
    NSDateComponents *midnightComponents = [[NSDateComponents alloc] init];
    [midnightComponents setYear:[todayComponents year]];
    [midnightComponents setMonth:[todayComponents month]];
    [midnightComponents setDay:[todayComponents day]];
    [midnightComponents setHour:0];
    [midnightComponents setMinute:0];
    [midnightComponents setSecond:0];
    
    midnight = [calendar dateFromComponents:midnightComponents];
    return midnight;
}

+(NSDate*)dayStart:(NSDate *)today
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:today];
    [comp setMinute:0];
    [comp setHour:0];
    [comp setSecond:0];
    return [cal dateFromComponents:comp];
}

+(NSDate*)dayEnd:(NSDate*)today
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:today];
    
    [comp setMinute:59];
    [comp setHour:23];
    [comp setSecond:0];
    return [cal dateFromComponents:comp];
}

+(bool)isCurrentDay:(NSDate*)date
{
    bool result = NO;
    NSDate *todayStart = [DateHelper dayStart:[DataStoreSingleton sharedInstance].currentDate];
    NSDate *todayEnd = [DateHelper dayEnd:[DataStoreSingleton sharedInstance].currentDate];
    if([todayStart compare:date] == NSOrderedAscending && [date compare:todayEnd] == NSOrderedAscending){
        result = YES;
    }
    
    return result;
}

@end
