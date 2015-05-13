//
//  MJNPSViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJNPSViewController.h"

@interface MJNPSViewController ()

@end

@implementation MJNPSViewController

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
    self.title = @"NPS Info";
    self.comments.text = self.currentJob.npsComment;
    NSString * thisNum = [NSString stringWithFormat:@"%@", self.currentJob.npsValue ];
    if ([thisNum integerValue] < 0)
        thisNum = @"N/A";
    self.truckTeamLabel.text = [NSString stringWithFormat:@"Previous Truck Team: %@", self.currentJob.nameOfLastTTUsed];
    self.npsLabel.text = [NSString stringWithFormat:@"NPS Score: %@", thisNum];
    float tSpent = [self.currentJob.totalSpent floatValue]/100;
    self.totalSpendLabel.text = [NSString stringWithFormat:@"Total Spend: $%0.02f", tSpent];
    self.numberPreviousJobs.text =[NSString stringWithFormat:@"Number of Previous Jobs: %@", self.currentJob.numOfJobs];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
