//
//  MJJobPaymentViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-02.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobPaymentViewController.h"
#import "MBProgressHUD.h"
#import "UserDefaultsSingleton.h"
#import "DataStoreSingleton.h"
#import "Route.h"
#import "DateHelper.h"
#import "MJJobPaymentDetailViewController.h"
#import "MJJobDetailViewCell.h"
#import "UIColor+ColorWithHex.h"
#import "Payment.h"
#import "DataStoreSingleton.h"
#import "LookupTableViewController.h"
#import "JNExpenseCell.h"
#import "FetchHelper.h"

@interface MJJobPaymentViewController ()
@property bool isDiscountOverridden;
@property bool isJunkChargeOverridden;
@property bool isInvoiceOverridden;
@property bool isTaxOverridden;

@end

@implementation MJJobPaymentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postPaymentSuccessful) name:@"PostPaymentSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postPaymentFailed) name:@"PostPaymentFailed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPaymentList) name:@"FetchPaymentsListComplete" object:nil];

    self.title = @"Payments";
    self.isDiscountOverridden = NO;
    [self registerForKeyboardNotifications];
    [self setupMenuBarButtonItems];
    [[FetchHelper sharedInstance] fetchPaymentsByJob:[self.currentJob.jobID integerValue]];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.activeField resignFirstResponder];
    [self.invoiceField resignFirstResponder];
    [self.discountField resignFirstResponder];
    [self.totalField resignFirstResponder];
    [self.junkChargeField resignFirstResponder];
}

-(void)refreshPaymentList
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.paymentsArray = [DataStoreSingleton sharedInstance].paymentList;
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( [DataStoreSingleton sharedInstance].currentJobPaymentID == self.currentJob.jobID)
    {
        
    }
    else
    {
        [DataStoreSingleton sharedInstance].paymentList = nil;
    }
    if ([self.currentJob.junkCharge integerValue] > 0)
    {
        self.invoiceField.text = self.currentJob.invoiceNumber;
        float tempJC = [self.currentJob.junkCharge floatValue]/100;
        self.junkChargeField.text =  [NSString stringWithFormat:@"$%0.02f", tempJC];
        if ([self.currentJob.programDiscountType isEqualToString:@"Percent"])
            self.discountField.text = [NSString stringWithFormat:@"%%%@", self.currentJob.discount];
        else
            self.discountField.text = [NSString stringWithFormat:@"$%@", self.currentJob.discount];

        [self.taxButton setTitle:[NSString stringWithFormat:@"%@%%", self.currentJob.taxType] forState:UIControlStateNormal];
        NSString *currentLookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
        if ([currentLookupMode isEqualToString:@"TAXTYPE"])
        {
            NSString *itemName = [[DataStoreSingleton sharedInstance] currentLookup].itemName;
            self.taxID =[[DataStoreSingleton sharedInstance] currentLookup].itemID;
            self.taxAmount =[[[DataStoreSingleton sharedInstance] currentLookup].itemName floatValue];
            [self.taxButton setTitle:[NSString stringWithFormat:@"%@%%", itemName] forState:UIControlStateNormal];
            [self.taxButton setTitle:[NSString stringWithFormat:@"%@%%", itemName]  forState:UIControlStateSelected];
        }
        if ([self.taxButton.titleLabel.text length] < 1)
        {
            [self.taxButton setTitle:@"Choose Tax" forState:UIControlStateNormal];
            [self.taxButton setTitle:@"Choose Tax" forState:UIControlStateSelected];
        }
        [self calculateTotal:nil];
        if (self.paymentsArray.count > 0)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(self.paymentsArray.count - 1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    else
    {
        self.paymentsArray = [DataStoreSingleton sharedInstance].paymentList;
        NSString *currentLookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
        if ([currentLookupMode isEqualToString:@"TAXTYPE"])
        {
            NSString *itemName = [[DataStoreSingleton sharedInstance] currentLookup].itemName;
            self.taxID =[[DataStoreSingleton sharedInstance] currentLookup].itemID;
            self.taxAmount =[[[DataStoreSingleton sharedInstance] currentLookup].itemName floatValue];
            [self.taxButton setTitle:[NSString stringWithFormat:@"%@%%", itemName] forState:UIControlStateNormal];
            [self.taxButton setTitle:[NSString stringWithFormat:@"%@%%", itemName] forState:UIControlStateSelected];
        }
        if ([self.taxButton.titleLabel.text length] < 1)
        {
            [self.taxButton setTitle:@"Choose Tax" forState:UIControlStateNormal];
            [self.taxButton setTitle:@"Choose Tax" forState:UIControlStateSelected];
        }
        [self calculateTotal:nil];
        if (self.paymentsArray.count > 0)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(self.paymentsArray.count - 1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    if (!self.isDiscountOverridden)
    {
        if ([self.currentJob.programDiscount integerValue] > [self.currentJob.discount integerValue])
        {
            if ([self.currentJob.programDiscountType isEqualToString:@"Percent"])

                self.discountField.text = [NSString stringWithFormat:@"%%%@", self.currentJob.programDiscount] ;
            else
                self.discountField.text = [NSString stringWithFormat:@"$%@", self.currentJob.programDiscount] ;

        }
        else
        {
            self.discountField.text = [NSString stringWithFormat:@"$%@", self.currentJob.discount] ;
        }
    }
    [self.tableView reloadData];
}
- (void)setupMenuBarButtonItems
{
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}
- (IBAction)editPayments:(id)sender
{
    if ([self.tableView isEditing])
        [self.tableView setEditing:NO animated:YES];
    else
        [self.tableView setEditing:YES animated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""]) return YES;
    unichar c = [string characterAtIndex:0];
    if (([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c]) || ([[NSCharacterSet punctuationCharacterSet] characterIsMember:c]))
    {
        NSString * discountNumber = [textField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        discountNumber = [discountNumber stringByReplacingOccurrencesOfString:@"%" withString:@""];
        if (textField == self.invoiceField)
            [textField setText:[NSString stringWithFormat:@"%@",discountNumber]];
        else if (([self.currentJob.programDiscountType isEqualToString:@"Percent"]) && (textField == self.discountField))
            [textField setText:[NSString stringWithFormat:@"%%%@",discountNumber]];
        else
            [textField setText:[NSString stringWithFormat:@"$%@",discountNumber]];
        if (textField == self.discountField)
            self.isDiscountOverridden = YES;
        return YES;
    }
    else
    {
        return NO;
    }
}
- (UIBarButtonItem *)rightMenuBarButtonItem
{
    float totalAmount = [self getTotal];
    NSString * totalNumber = [self.totalField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int tNumber = [totalNumber floatValue] *100;
    int tAmount = totalAmount * 100;
    if ((tNumber== tAmount) && ([self.invoiceField.text length] > 0))
        return [[UIBarButtonItem alloc] initWithTitle:@"Save Payment" style:UIBarButtonItemStylePlain target:self action:@selector(savePayments)];
    else
        return nil;
}


- (IBAction)addPayment:(id)sender
{
    MJJobPaymentDetailViewController *detailViewController = [[MJJobPaymentDetailViewController alloc] init];
    detailViewController.currentIndex = -10;
    float totalAmount = [self getTotal];
    NSString * totalNumber = [self.totalField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    float amountRemaining =   [totalNumber floatValue] - totalAmount;
    detailViewController.remainingAmount = amountRemaining;
    detailViewController.currentJob = self.currentJob;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    
}
-(void)savePayments
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSDate * date = [DataStoreSingleton sharedInstance].currentDate;
    NSString * junkChargeNumber = [self.junkChargeField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    NSString * totalNumber = [self.totalField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];

    NSString *dateString = [DateHelper dateToApiString: date];
    NSNumber * routeID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
    NSString * discountNumber = [self.discountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    discountNumber =[discountNumber stringByReplacingOccurrencesOfString:@"%" withString:@""];
    int jcNumber = [junkChargeNumber floatValue] * 100;
    int dNumber = 0;
    if ([self.currentJob.programDiscountType isEqualToString:@"Percent"])
         dNumber =[discountNumber floatValue]*jcNumber/100;
    else
        dNumber =[discountNumber floatValue]*100;
    int tNumber = [totalNumber floatValue]*100;
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/Payments?sessionID=%@&routeID=%@&dayID=%@&taxID=%d&invoiceNumber=%@&discount=%d&junkCharge=%d&subTotal=%d&total=%d", self.currentJob.jobID, sessionID, routeID, dateString, self.taxID, self.invoiceField.text,dNumber, jcNumber,jcNumber-dNumber,tNumber ];
    
    NSMutableArray *allParams = [[NSMutableArray alloc] init];
    
    for (Payment * thisPayment in self.paymentsArray)
    {
        float paymentTotal1 =(float) thisPayment.paymentAmount;
        int paymentTotal = paymentTotal1 * 100;
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.currentJob.jobID, @"jobID",
                                @"0", @"paymentID",
                                thisPayment.methodID , @"paymentMethodID",
                                thisPayment.paymentName, @"paymentMethod",
                                [NSString stringWithFormat:@"%d", paymentTotal], @"paymentSubTotal",
                                [NSString stringWithFormat:@"%d", paymentTotal], @"paymentTotal",
                                nil];
        [allParams addObject:params];
        
    }
    // assemble an array of the Payment objects
    NSMutableDictionary *allParams1 = [[NSMutableDictionary alloc] init];
    [allParams1 setObject:allParams forKey:@""];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[FetchHelper sharedInstance] postPayment:path params:allParams1];
    
    self.currentJob.junkCharge = [NSNumber numberWithInt:jcNumber];
    self.currentJob.total = [NSString stringWithFormat:@"%d", tNumber];
}

- (void)postPaymentSuccessful
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.currentJob.invoiceNumber = self.invoiceField.text;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postPaymentFailed
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *errorMessage = [NSString stringWithFormat:@"Unable to save the payment to Junknet:\n%@", [DataStoreSingleton sharedInstance].paymentErrors];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot save payment" message:errorMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [av show];
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)calculateTotal:(id)sender
{
    NSString * junkChargeNumber = [self.junkChargeField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];

    float subtotal = [junkChargeNumber floatValue];
    float tax = self.taxAmount;
    NSString * discountNumber = [self.discountField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    discountNumber =[discountNumber stringByReplacingOccurrencesOfString:@"%" withString:@""];
    float discount = [discountNumber floatValue];
    float discountPrice = 0;
    if ([self.currentJob.programDiscountType isEqualToString:@"Percent"])
        discountPrice = subtotal -discount*subtotal/100;
    else
        discountPrice = subtotal -discount;
    float total = discountPrice+ (discountPrice * tax * 0.01);
    if (total < 0)
        total = 0;
    self.totalField.text = [NSString stringWithFormat:@"$%.02f", total];
    [self.tableView reloadData];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.paymentsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JNExpenseCell";
    JNExpenseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JNExpenseCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.detailTextLabel.text = @"payment";
    Payment* thisPayment = [self.paymentsArray objectAtIndex:indexPath.row];
    float paymentAmount = thisPayment.paymentAmount;
    cell.amountLabel.text = [NSString stringWithFormat:@"$%.02f", paymentAmount];//  thisPayment.paymentAmount;
    cell.accountLabel.text = [NSString stringWithFormat:@"%@", thisPayment.paymentName];
    return cell;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
    UIView* customView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 60.0)];
    /* make button one pixel less high than customView above, to account for separator line */
    UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(-30, 1, 320, 60)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor=[UIColor blackColor];
    float totalAmount = [self getTotal];
    label.numberOfLines = 3;
    label.textAlignment = NSTextAlignmentRight;
    NSString * totalNumber = [self.totalField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    int tNumber = [totalNumber floatValue] *100;
    int tAmount = totalAmount * 100;
    label.text =  [NSString stringWithFormat:@"Total of Payments = $%.02f\nTotal Required = $%.02f", totalAmount, [totalNumber floatValue] - totalAmount];
    if (tNumber == tAmount)
        customView.backgroundColor = [UIColor colorWithRed:127.0/255.0 green: 186.0/255.0 blue: 0.0 alpha: 0.7];
    else
        customView.backgroundColor = [UIColor colorWithRed:227.0/255.0 green: 0.0/255.0 blue: 0.0 alpha: 0.7];
    [self setupMenuBarButtonItems];
    [customView addSubview:label];
    return customView;
}
- (float) getTotal
{
    float tempTotal = 0;
    for (Payment *thisPayment in self.paymentsArray)
    {
        tempTotal += thisPayment.paymentAmount;
    }
    return tempTotal;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
}
- (IBAction)showTaxList:(id)sender
{
    [self showListView:@"TAXTYPE" itemID:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJJobPaymentDetailViewController *vc = [[MJJobPaymentDetailViewController alloc] init];
    vc.currentJob = self.currentJob;
    int section, index;
    section = indexPath.section;
    index = indexPath.row; // where the expense object is within the array
    float totalAmount = [self getTotal];
    NSString * totalNumber = [self.totalField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    float amountRemaining =   [totalNumber floatValue] - totalAmount;
    Payment* thisPayment = [self.paymentsArray objectAtIndex:indexPath.row];
    vc.currentPayment = thisPayment;
    vc.currentIndex = index;
    vc.methodID = [thisPayment.methodID integerValue];
    vc.remainingAmount = amountRemaining;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)showListView:(NSString *)mode itemID:(int)i
{
    LookupTableViewController *vc = [[LookupTableViewController alloc] init];
    vc.mode = mode;
    vc.itemID = i;
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.paymentsArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

@end
