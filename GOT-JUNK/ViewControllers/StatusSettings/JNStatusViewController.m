//
//  JNStatusViewController.m
//  Example
//
//  Created by Mark Pettersson on 2013-07-17.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "JNStatusViewController.h"
#import <MapKit/MapKit.h>
#import "MFSideMenuContainerViewController.h"
#import "UserDefaultsSingleton.h"
#import "Flurry.h"
#import "DataStoreSingleton.h"
#import "FetchHelper.h"

@interface JNStatusViewController ()
{
    CLLocationManager *locationManager;
}

@end

@implementation JNStatusViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Setting locationManager to nil seems to cause some crashes on some devices
    //locationManager = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:@"FetchTestSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:@"FetchServerUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:@"FetchFailedServerDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:@"FetchFailedNoInternet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:@"FetchInternetUp" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewVersion) name:@"UpdateAvailable" object:nil];

    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];

    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    BOOL locationAllowed = [CLLocationManager locationServicesEnabled];    
    if (locationAllowed==NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [self updateStatus];
    
    NSString *appVersion = [UserDefaultsSingleton appVersion];
    self.versionLabel.text = [NSString stringWithFormat:@"Junknet Mobile Version: %@", appVersion];

    [self.welcomeLabel setText:[NSString stringWithFormat:@"User: %@", [[UserDefaultsSingleton sharedInstance] getUserFullName] ]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.getVersionButton setHidden:YES];
    [self.versionStatusLabel setHidden:YES];
    
    [self newVersionCheck];
}

- (void)didReceiveMemoryWarning
{		
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}	

- (void)updateStatus
{
    if( [DataStoreSingleton sharedInstance].isInternetLive == YES )
    {
        self.imageView.hidden = NO;
        self.imageViewEx.hidden = YES;
    }
    else
    {
        self.imageView.hidden = YES;
        self.imageViewEx.hidden = NO;
    }
    
    if( [DataStoreSingleton sharedInstance].isJunkNetLive == YES )
    {
        self.imageView2.hidden = NO;
        self.imageView2Ex.hidden = YES;
    }
    else
    {
        self.imageView2Ex.hidden = NO;
        self.imageView2.hidden = YES;
    }
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
    {
        self.imageView3.hidden = NO;
        self.imageView3Ex.hidden = YES;
    }
    else
    {
        self.imageView3.hidden = YES;
        self.imageView3Ex.hidden = NO;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];

    [self updateStatus];
}

- (void)locationManager:(CLLocationManager *)inManager didFailWithError:(NSError *)inError
{
    if (inError.code ==  kCLErrorDenied)
    {
        NSLog(@"Location manager denied access - kCLErrorDenied");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs://"]];

        // your code to show UIAlertView telling user to re-enable location services
        // for your app so they can benefit from extra functionality offered by app
    }
}

# pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( actionSheet.tag == 1 )
    {
        if (buttonIndex == 0)
        {
            NSString* launchUrl = [[DataStoreSingleton sharedInstance].appUpgradeInfo objectForKey:@"applicationURL"];

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:launchUrl]];
        }
        return;
    }
}

-(void)newVersionCheck
{
    [[FetchHelper sharedInstance] checkAppUpgrade];
}

- (void)updateNewVersion
{
    [self.getVersionButton setHidden:NO];
    [self.versionStatusLabel setHidden:NO];
    [self.versionStatusLabel setText:@"A new version is available."];
}

- (IBAction)getVersionPressed:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"A newer version of JunkNet Mobile is available.  Would you like to install this upgrade?"]
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  destructiveButtonTitle:@"Yes!"
                                  otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

@end
