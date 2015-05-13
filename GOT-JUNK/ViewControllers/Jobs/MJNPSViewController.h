//
//  MJNPSViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
@interface MJNPSViewController : UIViewController
@property (strong) IBOutlet UILabel *npsLabel;
@property (strong) IBOutlet UILabel *truckTeamLabel;
@property (strong) IBOutlet UILabel *totalSpendLabel;
@property (strong) IBOutlet UILabel *numberPreviousJobs;

@property (strong) IBOutlet UITextView *comments;
@property (strong)  Job *currentJob;

@end
