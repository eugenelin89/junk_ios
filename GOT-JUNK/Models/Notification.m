//
//  Notification.m
//  GOT-JUNK
//
//  Created by David Block on 2015-04-08.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Notification.h"

@implementation Notification

@synthesize notificationId;
@synthesize notificationText;
@synthesize textHeight;
@synthesize notificationDateDisplay;
@synthesize notificationModeText;
@synthesize isAccepted;
@synthesize jobID;
@synthesize isJobViewable;

- (Notification*)initFromDict:(NSDictionary *)dict
{

    // Set the ID
    //
    if (![[dict objectForKey:@"dispatchID"] isKindOfClass:[NSNull class]])
    {
        self.notificationId = [dict objectForKey:@"dispatchID"];
    }
    
    // Set the Date text
    //
    self.notificationDateDisplay = [self getDateText:[dict objectForKey:@"receiveDate"]];
    
    // Determine if the notification was accepted
    //
    if (![[dict objectForKey:@"dispatchID"] isKindOfClass:[NSNull class]])
    {
        self.isAccepted = ([[dict objectForKey:@"isDispatchAccepted"] intValue] == 1);
    }

    // Determine if the notification has a job to view
    //
    [self setJobToView:dict];
    
    // Set the detail text and height of the deatil text
    //
    [self setNotificationTextAndHeight:[dict objectForKey:@"content"]];
    

    
    return self;
}

- (NSString*)getDateText:(NSString*)dateIn
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd yyyy hh:mma"];
    NSDate *date = [dateFormat dateFromString:dateIn];
    if( date != nil )
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

        if( components.year == componentsToday.year && components.month == componentsToday.month && components.day == componentsToday.day )
        {
            NSDateFormatter *dateFormatTime = [[NSDateFormatter alloc] init];
            [dateFormatTime setDateFormat:@"h:mma"];
            
            return [dateFormatTime stringFromDate:date];
        }
    }
    
    return dateIn;
}

- (void)setJobToView:(NSDictionary*)dict
{
    
    if (![[dict objectForKey:@"jobID"] isKindOfClass:[NSNull class]])
    {
        self.jobID = [[dict objectForKey:@"jobID"] intValue];
    }
    
    if (![[dict objectForKey:@"dispatchMode"] isKindOfClass:[NSNull class]])
    {
        NSString *mode = [dict objectForKey:@"dispatchMode"];
        self.isJobViewable = ([mode isEqualToString:@"Add-On"] == YES ||
                              [mode isEqualToString:@"Resched"] == YES ||
                              [mode isEqualToString:@"Online Add-On"] == YES ||
                              [mode isEqualToString:@"Online Resched"] == YES) ;
        self.notificationModeText = mode;
        
    }
    else
    {
        self.isJobViewable = NO;
    }
    

    
}

- (void)setNotificationTextAndHeight:(NSString*)text
{
    self.notificationText = text;
    
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(360, 20000) lineBreakMode:NSLineBreakByWordWrapping];
    self.textHeight = MIN(textSize.height, 100.0f);
}


@end
