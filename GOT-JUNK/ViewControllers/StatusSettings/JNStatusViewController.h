//
//  JNStatusViewController.h
//  Example
//
//  Created by Mark Pettersson on 2013-07-17.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "JunkViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface JNStatusViewController : JunkViewController <CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIImageView* imageView2;
@property (nonatomic, retain) IBOutlet UIImageView* imageView3;
@property (nonatomic, retain) IBOutlet UIImageView* imageViewEx;
@property (nonatomic, retain) IBOutlet UIImageView* imageView2Ex;
@property (nonatomic, retain) IBOutlet UIImageView* imageView3Ex;
@property (nonatomic, retain) IBOutlet UILabel* welcomeLabel;
@property (nonatomic, retain) IBOutlet UILabel* versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *getVersionButton;
@property (weak, nonatomic) IBOutlet UILabel *versionStatusLabel;

- (IBAction)getVersionPressed:(UIButton *)sender;

@end
