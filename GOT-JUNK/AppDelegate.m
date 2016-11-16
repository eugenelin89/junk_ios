//
//  AppDelegate.m
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 1/22/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//BWSPKTGCMDWFGJK9W4R9

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "DateHelper.h"
#import "Flurry.h"
#import "MJCalendarViewController.h"
#import "JunkSideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "UserDefaultsSingleton.h"
#import "DataStoreSingleton.h"
#import "AFHTTPRequestOperation.h"
#import "FetchHelper.h"
#import "UIColor+ColorWithHex.h"



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
    if (getenv("runningTests"))
    {
        return YES;
    }
#endif

    // Create a guid and make it installation ID if not already exist.
    // This will help for tracking.
    [[UserDefaultsSingleton sharedInstance] setInstallationID:[[NSProcessInfo processInfo] globallyUniqueString]];

    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"BWSPKTGCMDWFGJK9W4R9"];
    [Flurry setDebugLogEnabled:YES];

    [DataStoreSingleton addEvent:@"Launch"];

    
    //LIVE Parse appID and Key
     	
    //[Parse setApplicationId:@"G7PdwnD2JF8tuKFKlSJ46Lb7MM8jV1JoSgWYBepV" clientKey:@"qyGI54YdFFj2UDMs4ztNQUXS8bcEOQXidTNDKFXs"];
    
    // Dev/Staging Parse appID and Key
    
    //[Parse setApplicationId:@"DHDzAGrkmxNCBeoqgjm4PvnBNIiUWwXuuIWNFZJT"  clientKey:@"TqWYkY5b7hJEqhOCR9UKspE8Ndq7FoIXwZTk82AC"];
    
    
    [self setupNotifications:application];

    [self setLocationCoordinates];
    
    [self setWindows];
    
    
    [DataStoreSingleton sharedInstance]; // make sure DataStoreSingleton gets initialized.

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [DataStoreSingleton addEvent:@"ResignForegroundActive"];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
 
    [[FetchHelper sharedInstance] fetchJobListForDefaultRouteAndCurrentDate];
    [[DataStoreSingleton sharedInstance] forwardCache];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UserDefaultsSingleton * userDefaults = [UserDefaultsSingleton sharedInstance];
    [userDefaults flushUserAcknowledgedDispatches];
    [userDefaults setDateAcknowledgedDispatchesCleared:[NSDate date]];
    
    [DataStoreSingleton addEvent:@"BecomeForegroundActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [DataStoreSingleton addEvent:@"Terminate"];

}

- (void)setupNotifications:(UIApplication*)application
{
    UIRemoteNotificationType remoteNotificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    UIUserNotificationType userNotificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
            declineAction.identifier = @"declineAction";
            declineAction.activationMode = UIUserNotificationActivationModeBackground;
            declineAction.title = @"Snooze";
            declineAction.destructive = YES;
            
            UIMutableUserNotificationAction *answerAction = [[UIMutableUserNotificationAction alloc] init];
            answerAction.identifier = @"answerAction";
            answerAction.activationMode = UIUserNotificationActivationModeForeground;
            answerAction.title = @"View Job";
            
            UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
            category.identifier = @"incomingCall"; //category name to send in the payload
            [category setActions:@[answerAction,declineAction] forContext:UIUserNotificationActionContextDefault];
            [category setActions:@[answerAction,declineAction] forContext:UIUserNotificationActionContextMinimal];
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:[NSSet setWithObjects:category,nil]];
            [application registerUserNotificationSettings:settings];
        }
        else
        {
            //register to receive notifications
            [application registerForRemoteNotificationTypes:remoteNotificationTypes];
        }
    }
    else
    {
        [application registerForRemoteNotificationTypes:remoteNotificationTypes];
    }
}

- (void)setLocationCoordinates
{
    @try
    {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        
        // for iOS 8+, need to explicitly make location service request in code.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            // Requesting for location service when the app is in foreground.
            [locationManager requestWhenInUseAuthorization];
        }
        
        [locationManager startUpdatingLocation];
        

        CLLocation *location = locationManager.location;
        [Flurry setLatitude:location.coordinate.latitude
                  longitude:location.coordinate.longitude
         horizontalAccuracy:location.horizontalAccuracy
           verticalAccuracy:location.verticalAccuracy];
        [[UserDefaultsSingleton sharedInstance] setLastKnownLocation:location.coordinate];
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_001" message:error exception:exception];
    }
}



- (void)setWindows
{
    @try
    {
        UIColor *colG = [UIColor getJunkColorBackground];
        UIColor *colB = [UIColor getJunkColorForeground];

        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[MJCalendarViewController alloc] initWithNibName:@"MJCalendarViewController" bundle:nil]];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        {
            [navController.navigationBar setBarTintColor:colG];
        }
        else
        {
            [navController.navigationBar setTintColor:colG];
        }

        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        colB,NSForegroundColorAttributeName,
                                        colB,NSBackgroundColorAttributeName,
                                        nil];
        navController.navigationBar.titleTextAttributes = textAttributes;
        
        
        JunkSideMenuViewController *leftMenuViewController = [[JunkSideMenuViewController alloc] init];
        MFSideMenuContainerViewController *calendarViewController = [MFSideMenuContainerViewController
                                                                     containerWithCenterViewController:navController
                                                                     leftMenuViewController:leftMenuViewController
                                                                     rightMenuViewController:nil];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = calendarViewController;
        [self.window makeKeyAndVisible];
        
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_002" message:error exception:exception];
    }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    [PFPush handlePush:userInfo];

    if ([identifier isEqualToString:@"declineAction"])
    {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = [userInfo objectForKey:@"content"];
        //notif.alertBody = [NSString stringWithFormat:@"%@:JobID%@", [userInfo objectForKey:@"dispatchType"], [userInfo objectForKey:@"jobid"]];
        NSDate *date = [NSDate date];
        notif.fireDate = [date dateByAddingTimeInterval:600];
        notif.soundName = @"update.caf";

        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
    else if ([identifier isEqualToString:@"answerAction"])
    {
        NSString *jobID = [userInfo objectForKey:@"jobid"];
        [self viewJob:jobID];
    }
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    // Using Device Token as Unique Identifier
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UserDefaultsSingleton sharedInstance] setDeviceID:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
//    notif.alertBody = [NSString stringWithFormat:@"%@:JobID%@", [userInfo objectForKey:@"dispatchType"], [userInfo objectForKey:@"jobid"]];
    NSDate *date = [NSDate date];
    notif.fireDate = [date dateByAddingTimeInterval:600];
    notif.userInfo = userInfo;
    notif.alertBody = [userInfo objectForKey:@"content"];
    notif.soundName = @"update.caf";
    [[UIApplication sharedApplication] cancelLocalNotification:notif];
    
    [PFPush handlePush:userInfo];
    
    NSString *jobID = [userInfo objectForKey:@"jobid"];
    [self viewJob:jobID];
    
    // Forward Cache
    [[DataStoreSingleton sharedInstance] forwardCache];
    
    
}



- (void)viewJob:(NSString*)jobID
{
    NSLog(@"View job from Notifiations, jobID = %@", jobID);
    if (jobID)
    {
        [[UserDefaultsSingleton sharedInstance] setJobToView:jobID];
        [[FetchHelper sharedInstance] fetchJobDetaislForJob:[NSNumber numberWithInteger:[jobID integerValue]]];
    }
}

@end
