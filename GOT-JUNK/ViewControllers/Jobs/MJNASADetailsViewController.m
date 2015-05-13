//
//  MJNASADetailsViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-24.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJNASADetailsViewController.h"

@interface MJNASADetailsViewController ()

@end

@implementation MJNASADetailsViewController

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
    if ([self.currentJob.programDiscountType isEqualToString:@"Percent"])
        self.programNotes.text = [NSString stringWithFormat:@"Promo Code: %@\nDiscount: %@%%\nProgram Notes: %@", self.currentJob.promoCode,self.currentJob.programDiscount, self.currentJob.programNotes];
    else
        self.programNotes.text = [NSString stringWithFormat:@"Promo Code: %@\nDiscount: $%@\nProgram Notes: %@", self.currentJob.promoCode,self.currentJob.programDiscount, self.currentJob.programNotes];

    self.title = @"Special Instructions";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
