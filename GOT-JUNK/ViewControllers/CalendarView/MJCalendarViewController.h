//
//  MJCalendarViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJCollectionViewCalendarLayout.h"

#import "Job.h"
@interface MJCalendarViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MJCollectionViewDelegateCalendarLayout, UIActionSheetDelegate, UIAlertViewDelegate>

- (IBAction)nextWasPressed:(id)sender;
- (IBAction)previousWasPressed:(id)sender;
- (IBAction)scrollTo:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) IBOutlet UIButton *nextButton1;
@property (nonatomic, strong) IBOutlet UIButton *prevButton1;


- (void)updateState;

@end
