//
//  MJExpenseAccountsTableViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-25.
//  Copyright (c) 2013 Gargoyle Software. All rights reserved.
//

#import "MJExpenseAccountsTableViewController.h"
#import "FetchHelper.h"
#import "DataStoreSingleton.h"
#import "ExpenseAccount.h"
@interface MJExpenseAccountsTableViewController ()

@end

@implementation MJExpenseAccountsTableViewController

@synthesize expenseAccountsList = _expenseAccountsList;
@synthesize expenseAccountsListTableView;


/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshExpenseAccountsList) name:@"FetchExpenseAccountsListComplete" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Expense Accounts";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([DataStoreSingleton sharedInstance].expenseAccountsList && [[DataStoreSingleton sharedInstance].expenseAccountsList count] > 0)
    {
        self.expenseAccountsList = [DataStoreSingleton sharedInstance].expenseAccountsList;
        [self.expenseAccountsListTableView reloadData];
    }
    else
    {
        [self getExpenseAccountsList];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getExpenseAccountsList{
    [[FetchHelper sharedInstance] fetchExpenseAccountsList:1];
    
    // use this list and populate the table view.
}

- (void)refreshExpenseAccountsList
{
    self.expenseAccountsList = [DataStoreSingleton sharedInstance].expenseAccountsList;
    [self.expenseAccountsListTableView reloadData];
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
    
    return [self.expenseAccountsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    ExpenseAccount *expenseAccount = [self.expenseAccountsList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = expenseAccount.expenseAccountName;
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
    
    
    [DataStoreSingleton sharedInstance].currentExpense.expenseAccountID =((ExpenseAccount*) [self.expenseAccountsList objectAtIndex:indexPath.row]).expenseAccountID;
  [DataStoreSingleton sharedInstance].currentExpense.expenseAccount =((ExpenseAccount*) [self.expenseAccountsList objectAtIndex:indexPath.row]).expenseAccountName;
    [self.navigationController popViewControllerAnimated:YES];

}

@end
