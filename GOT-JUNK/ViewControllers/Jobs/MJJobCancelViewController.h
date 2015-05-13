//
//  MJJobCancelViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJJobCancelViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextView* cancelComments;
@property (nonatomic, strong) IBOutlet UIButton* cancelReasonButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelPeriodButton;


- (IBAction)cancelJobReason:(id)sender;
- (IBAction)cancelJobTime:(id)sender;
- (IBAction)cancelJobPeriod:(id)sender;

@property NSNumber* currentJobID;
@property int cancelReasonID;
@property int cancelPeriodID;

@end
