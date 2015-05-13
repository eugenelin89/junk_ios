//
//  MJJobCancelViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobCancelViewController.h"
#import "MJJobCancelReasonsViewController.h"
#import "FetchHelper.h"
#import "LookupTableViewController.h"
#import "DataStoreSingleton.h"
#import "MBProgressHUD.h"
#import "Flurry.h"

@interface MJJobCancelViewController ()

@end

@implementation MJJobCancelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelJobSuccessful) name:@"CancelJobSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelJobFailed) name:@"CancelJobFailed" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Cancel Job";
    [self setupMenuBarButtonItems];
    self.cancelComments.layer.borderWidth = 1.0f;
    self.cancelComments.layer.borderColor = [[UIColor grayColor] CGColor];
    // Do any additional setup after loading the view from its nib.
    self.cancelReasonID = 0;
    // Default cancellation period will be set to "Welcome Call".
    self.cancelPeriodID = 1;
}

- (void) viewDidAppear:(BOOL)animated
{
    // Update the appropriate label depending on which tableviewcontroller screen we just returned from.
    [super viewDidAppear:animated];
    NSString *currentLookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
    Lookup *currentLookup = [DataStoreSingleton sharedInstance].currentLookup;
    NSString *itemName = [DataStoreSingleton sharedInstance].currentLookup.itemName;
    
    if([currentLookupMode isEqualToString:@"CancelReason"])
    {
        [self.cancelReasonButton setTitle:itemName forState:UIControlStateNormal];
        self.cancelReasonID = currentLookup.itemID;
    }
    else if ([currentLookupMode isEqualToString:@"cancelPeriod"]){
        [self.cancelPeriodButton setTitle:itemName forState:UIControlStateNormal];
        // Check if cancel period has changed; if so, reset cancellation reason.
        if (self.cancelPeriodID != currentLookup.itemID){
            self.cancelReasonID = 0;
            [self.cancelReasonButton setTitle:@"Choose" forState:UIControlStateNormal];
        }
        self.cancelPeriodID = currentLookup.itemID;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelJobReason:(id)sender
{
    LookupTableViewController *vc = [[LookupTableViewController alloc] init];
    vc.mode = @"CancelReason";
    vc.itemID = self.cancelPeriodID;
    vc.languageID = 1;
    [self.navigationController pushViewController:vc
                                         animated:YES];
}
- (IBAction)cancelJobPeriod:(id)sender
{
    LookupTableViewController *vc = [[LookupTableViewController alloc] init];
    vc.mode = @"cancelPeriod";
    vc.itemID = 1;
    vc.languageID = 1;
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (BOOL)validateFormSubmit
{
    // We need to have a non-null cancellation reason and period
    NSString *errorMessage = [[NSString alloc] init];
    if (self.cancelReasonID == 0)
    {
        errorMessage = @"You must set a cancellation reason.";
    }
    else if (self.cancelPeriodID == 0)
    {
        errorMessage = @"You must set a cancellation period.";
    }
    if (errorMessage && errorMessage.length > 0){
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Stop it right there ..." message:errorMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [av show];
        return NO;
    }
    return YES;
}

- (IBAction)cancelJobTime:(id)sender
{
    // run validation
    if (![self validateFormSubmit])
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[FetchHelper sharedInstance] cancelJob:self.currentJobID withReason:self.cancelReasonID periodID:self.cancelPeriodID comments:self.cancelComments.text];
}

- (void)cancelJobSuccessful
{
    [Flurry logEvent:@"Cancel Job"];

    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)cancelJobFailed
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cancel Job Unsuccessful" message:@"Unable to cancel the job on JunkNet" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [av show];
}

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Cancel Job" style:UIBarButtonItemStylePlain target:self action:@selector(cancelJobTime:)];
}
@end
