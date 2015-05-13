//
//  MJJobCancelReasonsViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobCancelReasonsViewController.h"

@interface MJJobCancelReasonsViewController ()

@end

@implementation MJJobCancelReasonsViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
//    if ([DataStoreSingleton sharedInstance].cancelReasonList && [[DataStoreSingleton sharedInstance].cancelReasonList count] > 0)
//    {
//     //   self.expensePaymentMethodsList = [DataStoreSingleton sharedInstance].cancelReasonList;
//       // [self.expensePaymentMethodsListTableView reloadData];
//    }
//    else
//    {
//        //[self getExpensePaymentMethodsList];
//        
//    }
}
@end
