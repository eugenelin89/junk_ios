//
//  SettingsViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 4/22/2014.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import "SettingsViewController.h"
#import "Flurry.h"
#import "UserDefaultsSingleton.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UserDefaultsSingleton *defaults = [UserDefaultsSingleton sharedInstance];
    [self.colorSwitch setOn:[defaults getUserColorPref]];
    [self.mapSwitch setOn:[defaults getUserColorPref]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pressColorSwitch:(id)sender
{
    [[UserDefaultsSingleton sharedInstance] setColorPreference:[self.colorSwitch isOn]];
    
    if ([self.colorSwitch isOn])
    {
        [Flurry logEvent:@"Use Junknet Colors"];
    }
    else
    {
        [Flurry logEvent:@"Turn Off Junknet Colors"];
    }
}

- (IBAction)pressMapSwitch:(id)sender
{
    if( [[UserDefaultsSingleton sharedInstance] setMapSwitch:[self.mapSwitch isOn]] == YES )
    {
        [Flurry logEvent:@"Use Google Maps"];
    }
    else
    {
        [self.mapSwitch setOn:NO];
        [Flurry logEvent:@"Turn Off Google Maps"];
        UIAlertView *thisAlert = [[UIAlertView alloc] initWithTitle:@"No Google Maps" message:@"You must install Google Maps on your phone to enable this feature" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [thisAlert show];
    }
}

@end
