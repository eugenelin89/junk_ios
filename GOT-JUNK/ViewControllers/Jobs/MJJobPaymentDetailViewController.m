//
//  MJJobPaymentDetailViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-02.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobPaymentDetailViewController.h"
#import "DataStoreSingleton.h"
#import "Payment.h"
#import "LookupTableViewController.h"

@interface MJJobPaymentDetailViewController ()

@end

@implementation MJJobPaymentDetailViewController

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
    self.title = @"Detail";
    [self setupMenuBarButtonItems];
    // Do any additional setup after loading the view from its nib.
}
- (void)setupMenuBarButtonItems
{
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}
- (UIBarButtonItem *)rightMenuBarButtonItem
{
        return [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(addPayment:)];
 
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *currentLookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
    NSString *itemName = [[DataStoreSingleton sharedInstance] currentLookup].itemName;
    if ([currentLookupMode isEqualToString:@"PAYMENTMETHODREVENUEALLJOURNAL"])
    {
       [self.paymentTypeButton setTitle:itemName forState:UIControlStateNormal];// = itemName;
       self.methodID = [[DataStoreSingleton sharedInstance] currentLookup].itemID;
    }
    if (self.currentPayment.paymentAmount > 0)
    {
        self.paymentField.text = [NSString stringWithFormat:@"$%.02f", self.currentPayment.paymentAmount];
        self.methodID = [self.currentPayment.methodID integerValue];
        [self.paymentTypeButton setTitle:self.currentPayment.paymentName forState:UIControlStateNormal];// = itemName;

    }
    self.amountLabel.text = [NSString stringWithFormat:@"Amount remaining: $%.02f",self.remainingAmount ];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addPayment:(id)sender
{
   if (![self.paymentTypeButton.titleLabel.text isEqualToString:@"Choose"])
   {
    if (self.currentIndex < 0)
    {
        Payment * tempPayment = [[Payment alloc]init];
        tempPayment.paymentID = @0;
        tempPayment.paymentName = self.paymentTypeButton.titleLabel.text;
        NSString * paymentNumber = [self.paymentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        tempPayment.paymentAmount = [paymentNumber floatValue];
        tempPayment.methodID = [NSNumber numberWithInt: self.methodID];
        [[DataStoreSingleton sharedInstance].paymentList addObject:tempPayment];
        [[DataStoreSingleton sharedInstance] setCurrentJobPaymentID:self.currentJob.jobID];
        [DataStoreSingleton sharedInstance].currentLookupMode = @"";
        [self.paymentTypeButton setTitle:@"Choose" forState:UIControlStateNormal];// = itemName;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        Payment * tempPayment = [[Payment alloc]init];
        tempPayment.paymentID = @0;
        tempPayment.paymentAmount = [self.paymentField.text floatValue];
        NSString * paymentNumber = [self.paymentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        tempPayment.paymentName =  self.paymentTypeButton.titleLabel.text;
        tempPayment.paymentAmount = [paymentNumber floatValue];
        tempPayment.methodID = [NSNumber numberWithInt: self.methodID];
        if ([[DataStoreSingleton sharedInstance].paymentList count] > 0)
            [[DataStoreSingleton sharedInstance].paymentList  replaceObjectAtIndex:self.currentIndex withObject:tempPayment];
        else
            [[DataStoreSingleton sharedInstance].paymentList addObject:tempPayment];
        [DataStoreSingleton sharedInstance].currentLookupMode = @"";
        [self.paymentTypeButton setTitle:@"Choose" forState:UIControlStateNormal];// = itemName;
        [self.navigationController popViewControllerAnimated:YES];
    }
   }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Must choose payment method" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    if ([string isEqualToString:@""]) return NO;
    unichar c = [string characterAtIndex:0];
    if (([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c]))
    {
        NSString * discountNumber = [textField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        discountNumber = [discountNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSScanner *scanner = [NSScanner scannerWithString:discountNumber];
        NSCharacterSet *zeros = [NSCharacterSet
                                 characterSetWithCharactersInString:@"0"];
        [scanner scanCharactersFromSet:zeros intoString:NULL];
        
        // Get the rest ofthe string and log it
        discountNumber = [discountNumber substringFromIndex:[scanner scanLocation]];
        if ([discountNumber length] == 1)
            [textField setText:[NSString stringWithFormat:@"$0.0%@",discountNumber]];
        else if ([discountNumber length] == 2)
            [textField setText:[NSString stringWithFormat:@"$0.%@",discountNumber]];
        else if ([discountNumber length] > 2)

        {
            NSString * cents=[discountNumber substringFromIndex:MAX((int)[discountNumber length]-2, 0)];
            NSString * dollars=[discountNumber substringToIndex:[discountNumber length]-2];
            [textField setText:[NSString stringWithFormat:@"$%@.%@",dollars,cents]];
        }
        return NO;
    }
    else
    {
        return NO;
    }
}
- (IBAction)showExpensePaymentMethodsList:(id)sender
{
    self.currentPayment = nil;
    [self showListView:@"PAYMENTMETHODREVENUEALLJOURNAL" itemID:0];
}
- (void)showListView:(NSString *)mode itemID:(int)i
{
    LookupTableViewController *vc = [[LookupTableViewController alloc] init];
    vc.mode = mode;
    vc.itemID = i;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
