//
//  SettingsViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 4/22/2014.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import "JunkViewController.h"

@interface SettingsViewController : JunkViewController

@property (nonatomic, retain) IBOutlet UISwitch* colorSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* mapSwitch;

- (IBAction)pressColorSwitch:(id)sender;
- (IBAction)pressMapSwitch:(id)sender;

@end
