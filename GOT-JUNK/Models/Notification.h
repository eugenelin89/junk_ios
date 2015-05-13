//
//  Notification.h
//  GOT-JUNK
//
//  Created by David Block on 2015-04-08.
//  Copyright (c) 2015 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITextView;

@interface Notification : NSObject

@property (nonatomic, strong) NSNumber *notificationId;
@property (nonatomic, strong) NSString *notificationText;
@property float textHeight;
@property BOOL isAccepted;
@property (nonatomic, strong) NSString *notificationDateDisplay;
@property (nonatomic, strong) NSString *notificationModeText;
@property int jobID;
@property BOOL isJobViewable;

- (Notification*)initFromDict:(NSDictionary *)dict;

@end
