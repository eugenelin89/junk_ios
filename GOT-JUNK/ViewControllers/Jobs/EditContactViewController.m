//
//  EditContactViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "EditContactViewController.h"
#import "Job.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "FetchHelper.h"

@interface EditContactViewController ()

@end

@implementation EditContactViewController


- (id)initWithJob:(Job*)job
{
  self = [super initWithNibName: @"EditContactViewController" bundle: nil];
  if (self) {
    self.job = job;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEmailCompletedSuccessful) name:@"UpdateEmailCompleteSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEmailCompletedFailure) name:@"UpdateEmailCompleteFailure" object:nil];
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  [self setupNavBar];
self.title = @"Notes";

  self.containerView.layer.cornerRadius = 10;
  self.containerView.layer.borderWidth = 1;
  self.containerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

  self.emailtextField.text = self.job.clientEmail;
  self.nameLabel.text = self.job.clientName;

  [self.emailtextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UI

- (void)setupNavBar
{
  self.title = @"Edit Contact";

 // UIImage *buttonImage = [[UIImage imageNamed:@"navbar-button-blue.png"]
   //                       resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
  //UIImage *buttonImageHighlight = [[UIImage imageNamed:@"navbar-button-blue-press.png"]
    //                               resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];

  UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveContactInfo:)];
  //[rightItem setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  //[rightItem setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

  self.navigationItem.rightBarButtonItem = rightItem;
//
//  UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
//  [leftItem setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//  [leftItem setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//  self.navigationItem.leftBarButtonItem = leftItem;
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
# pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if ([alertView.title isEqualToString:@"Update Email Successful"])
  {
    [self popViewController];
  }
}

# pragma mark - Button IBActions

- (IBAction)saveContactInfo:(id)sender
{
    
    if (([self NSStringIsValidEmail:self.emailtextField.text]) || ([self.emailtextField.text length] == 0))
    {
        [self.emailtextField resignFirstResponder];
        [[FetchHelper sharedInstance] updateEmail:self.emailtextField.text forJob:self.job];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid E-mail" message:@"This is not a valid e-mail" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [av show];
    }
}

- (void)popViewController
{
  [self.navigationController popViewControllerAnimated:YES];
}

# pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.emailtextField)
  {
      [self saveContactInfo: textField];
  }

  [textField resignFirstResponder];

  return YES;
}

# pragma mark - Success / Fail

- (void)updateEmailCompletedSuccessful
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];

  self.job.clientEmail = self.emailtextField.text;

  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Email Successful" message:@"The email has been stored in JunkNet" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
  [av show];
}

- (void)updateEmailCompletedFailure
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];

  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Email Failed" message:@"The email could not be updated. Please try again." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
  [av show];
}

@end
