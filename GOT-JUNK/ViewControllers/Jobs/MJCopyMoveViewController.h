//
//  MJCopyMoveViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-16.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "MJCollectionViewCalendarLayout.h"

@interface MJCopyMoveViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MJCollectionViewDelegateCalendarLayout>
{
@private
    Job *_alertJob;
    NSDictionary *_jobsShowedAlert;
    BOOL _isAlertShowing;
}

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) Job *currentJob;
@property (nonatomic, retain) Job *copiedJob;

@property (nonatomic, strong) NSArray *jobList;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISwitch *uiSwitch;

- (IBAction)nextWasPressed:(id)sender;
- (IBAction)previousWasPressed:(id)sender;
- (IBAction)addTime:(id)sender;
- (IBAction)removeTime:(id)sender;
- (IBAction)addStartTime:(id)sender;
- (IBAction)removeStartTime:(id)sender;
- (IBAction)copyButton:(id)sender;

@property int indexJob;
@property int originalDuration;

@property BOOL isRed;
@property  NSInteger hour;
@property  NSInteger mins;
@property  NSInteger hourStart;
@property  NSInteger minsStart;
@property (nonatomic, retain) NSString * tempJobDuration;
@property (nonatomic, retain) NSString * tempJobStartTime;

@property (nonatomic, retain) NSString * tempJobEndTime;

@property (nonatomic, strong) NSDate * tempJobDate;
@property (nonatomic, strong) NSNumber * tempJobStartTimeOriginal;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *startLabel;

@property (nonatomic, strong) IBOutlet UILabel *customerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *startTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *customerCompanyLabel;
@property (nonatomic, strong) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end
