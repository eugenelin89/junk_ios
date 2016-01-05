//
//  AppDelegate.h
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 1/22/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
