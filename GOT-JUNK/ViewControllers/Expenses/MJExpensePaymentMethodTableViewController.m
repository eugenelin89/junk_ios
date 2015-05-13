//
//  MJExpensePaymentMethodTableViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-26.
//  Copyright (c) 2013 Gargoyle Software. All rights reserved.
//

#import "MJExpensePaymentMethodTableViewController.h"
#import "DataStoreSingleton.h"
#import "FetchHelper.h"
#import "PaymentMethod.h"

@interface MJExpensePaymentMethodTableViewController ()

@end

@implementation MJExpensePaymentMethodTableViewController

@synthesize expensePaymentMethodsList;
@synthesize expensePaymentMethodsListTableView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshExpensePaymentMethodsList) name:@"FetchExpensePaymentMethodsListComplete" object:nil]; 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.Title = @"Payment Methods";
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    if ([DataStoreSingleton sharedInstance].paymentMethodList && [[DataStoreSingleton sharedInstance].paymentMethodList count] > 0)
    {
        self.expensePaymentMethodsList = [DataStoreSingleton sharedInstance].paymentMethodList;
        [self.expensePaymentMethodsListTableView reloadData];
    }
    else
    {
        [self getExpensePaymentMethodsList];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getExpensePaymentMethodsList
{
    [[FetchHelper sharedInstance] fetchExpensePaymentMethods];
}
- (void)refreshExpensePaymentMethodsList
{
    self.expensePaymentMethodsList = [DataStoreSingleton sharedInstance].paymentMethodList;
    [self.expensePaymentMethodsListTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    // Return the number of rows in the section.
    
    return [self.expensePaymentMethodsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PaymentMethod *paymentMethod = [self.expensePaymentMethodsList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = paymentMethod.paymentName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    [DataStoreSingleton sharedInstance].currentPaymentMethod.paymentID = ((PaymentMethod*) [self.expensePaymentMethodsList objectAtIndex:indexPath.row]).paymentID;

    [DataStoreSingleton sharedInstance].currentPaymentMethod.paymentName = ((PaymentMethod*) [self.expensePaymentMethodsList objectAtIndex:indexPath.row]).paymentName;
    */
    
    
    [DataStoreSingleton sharedInstance].currentExpense.paymentMethodID = [((PaymentMethod*) [self.self.expensePaymentMethodsList objectAtIndex:indexPath.row]).paymentID intValue];
    [DataStoreSingleton sharedInstance].currentExpense.paymentMethod =((PaymentMethod*) [self.self.expensePaymentMethodsList objectAtIndex:indexPath.row]).paymentName;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
