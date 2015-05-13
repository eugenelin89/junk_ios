//
//  MJAdjustJobViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "MJCollectionViewCalendarLayout.h"

@interface MJAdjustJobViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, MJCollectionViewDelegateCalendarLayout>

@property (nonatomic, retain) Job *currentJob;
@property (nonatomic, strong) NSArray *jobList;
@property (nonatomic, strong) IBOutlet UILabel *customerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *customerCompanyLabel;

@property (nonatomic, strong) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, strong) IBOutlet UIStepper *timeStepper;
@property int indexJob;
@property  NSInteger hour;
@property  NSInteger mins;

- (IBAction)addTime:(id)sender;
- (IBAction)removeTime:(id)sender;
//- (IBAction)addStartTime:(id)sender;
//- (IBAction)removeStartTime:(id)sender;
- (IBAction)saveJobDuration:(id)sender;
- (IBAction)moveCopy:(id)sender;

@end
