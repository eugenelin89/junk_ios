//
//  MJExpensesTableViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-28.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJExpensesTableViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "JNExpenseDetailViewController.h"
#import "DataStoreSingleton.h"
#import "JNExpenseCell.h"
#import "UIColor+ColorWithHex.h"
#import "FetchHelper.h"
#import "Route.h"
#import "UserDefaultsSingleton.h"
#import "MBProgressHUD.h"
#import "DateHelper.h"
#import "Franchise.h"
#import "Flurry.h"

@interface MJExpensesTableViewController ()

@end

@implementation MJExpensesTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteExpenseSuccessful) name:@"SendDeleteExpenseSuccesful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteExpenseFailed) name:@"SendDeleteExpenseFailed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshExpensesList) name:@"FetchExpensesListComplete" object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [Flurry logEvent:@"Expense List"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self setupMenuBarButtonItems];
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];

    self.dateLabel.text = [DateHelper dateToJobListString:currentDate];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (void)deleteExpenseSuccessful
{
    // show the success message!
    
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Boom!" message:@"The expense was successfully deleted!  Way to cut spending!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [av show];
    
    [self setEditMode:YES];
    [self.tableView reloadData];
}

- (void)deleteExpenseFailed
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Failure!" message:@"The expense could not be deleted.  Please try again." delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    
    [av show];
}

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    UIBarButtonItem * buttonItem = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(rightSideMenuButtonPressed:)];
    return buttonItem;
}

- (IBAction)rightSideMenuButtonPressed:(id)sender
{
    [self setEditMode:![self.tableView isEditing]];
}

- (void)setEditMode:(BOOL)isEditing
{
    if (isEditing){
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.tableView setEditing:NO animated:YES];
        
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //[DataStoreSingleton sharedInstance].expensesDict = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *expensesDict = [[DataStoreSingleton sharedInstance] expensesDict];
    NSMutableArray *resourcesList = [DataStoreSingleton sharedInstance].resourcesList;
    
    // look up the list of the resources
    if (!resourcesList || resourcesList.count == 0){
        [self getResourcesData];
    }
    
    // load up the list of the expenses
    
    if ([self isEmptyExpensesDict:expensesDict]){
        [self getExpensesData];
    }
    else {
        self.expensesDict = [DataStoreSingleton sharedInstance].expensesDict;
        [self.tableView reloadData];
    }
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
    
    self.dateLabel.text = [DateHelper dateToJobListString:currentDate];
}

- (BOOL)isEmptyExpensesDict:(NSDictionary *)expensesDict
{
    if ((!expensesDict) || (expensesDict.count == 0)) return YES;
    
    // check if any of the inner arrays have items
    for (int i=0; i<expensesDict.count;i++){
        NSArray * expensesList = [expensesDict objectForKey:[[NSNumber alloc] initWithInt:i]];
        
        if (expensesList.count > 0) return NO;
    }
    return YES;
}

// gets run when the expenses list is loaded up through the webservice
- (void)refreshExpensesList
{
    self.expensesDict = [DataStoreSingleton sharedInstance].expensesDict;
    [self.tableView reloadData];
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}

// do call to get list of resources
- (void)getResourcesData
{
    
    [[FetchHelper sharedInstance] fetchResources:0];
}

// get our list of expenses by route
- (void)getExpensesData
{
    int routeID = [[[DataStoreSingleton sharedInstance] currentRoute].routeID integerValue];
    if (!routeID || routeID == 0){
        routeID = [[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] integerValue];
    }
    
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
    
    [[FetchHelper sharedInstance] fetchExpensesByRoute:routeID onDate:currentDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) headerTapped: (UIButton*)sender
{
    /* do what you want in response to section header tap */
    if ([DataStoreSingleton sharedInstance].isConnected)
    {
        JNExpenseDetailViewController *vc = [[JNExpenseDetailViewController alloc] init];
        Expense * expense = [[Expense alloc] init];
        expense.expenseTypeID = (sender.tag + 1);
        vc.myExpense.expenseTypeID = (sender.tag + 1);
        vc.myExpense = expense;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"You are in offline Mode.  You cannot create new expenses in offline mode" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // there are only three expense types: gas, disposal and misc
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // get the number of expenses per expenseTypeID
    
    NSNumber * sect = [[NSNumber alloc] initWithInt:(section + 1)];
    
    return [[[DataStoreSingleton sharedInstance].expensesDict objectForKey:sect] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"JNExpenseCell";
    
    JNExpenseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JNExpenseCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    cell.accountLabel.textColor = col2;
    cell.accountLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    
    
    Expense * thisExpense;
    
    // look up the expense in the expenses dictionary by ...
    //  - expenseTypeID (equiv to indexPath.section + 1)
    //  - index (equiv to indexPath.row) within the array held in each dict entry
    thisExpense = [[[DataStoreSingleton sharedInstance].expensesDict
                    objectForKey:[[NSNumber alloc] initWithInt:(int)(indexPath.section + 1)]
                    ]
                   objectAtIndex:(int)indexPath.row];
    
    cell.accountLabel.text = thisExpense.expenseAccount;
    cell.amountLabel.text = [NSString stringWithFormat:@"$ %.02f", (float)thisExpense.subTotal / 100];
    
    return cell;
}


#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Section %d", section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (UIView*) tableView: (UITableView*) tableView
viewForHeaderInSection: (NSInteger) section
{
    UIView* customView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 60.0)];
    customView.backgroundColor = [UIColor colorWithRed:127.0/255.0 green: 186.0/255.0 blue: 0.0 alpha: 0.7];
    
 
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(5.0, 10.0, 35.0, 35.0)];
    button.tag = section;
    button.backgroundColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    button.alpha = 1.0;
    
    
    [button setImage: [UIImage imageNamed:@"plus-icon.png" ] forState: UIControlStateNormal];
    
    /* Prepare target-action */
    [button addTarget: self action: @selector(headerTapped:)
     forControlEvents: UIControlEventTouchUpInside];
    UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 150, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter, UITextAlignmentLeft
    label.textColor=[UIColor blackColor];
    if (section == 0)
        label.text = @"Gas";
    if (section == 1)
        label.text = @"Disposal";
    if (section == 2)
        label.text = @"Miscellaneous";
    [customView addSubview:label];
    [customView addSubview: button];
    /* make button one pixel less high than customView above, to account for separator line */
    UIButton *button1 = [[UIButton alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 60.0)];
    button1.tag = section;
    button1.backgroundColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    button1.alpha = 1.0;
    
    
    [button1 setImage: [UIImage imageNamed:@"plus-icfon.png" ] forState: UIControlStateNormal];
    
    /* Prepare target-action */
    [button1 addTarget: self action: @selector(headerTapped:)
      forControlEvents: UIControlEventTouchUpInside];
    [customView addSubview: button1];

    return customView;
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.tableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray * expensesList = [[DataStoreSingleton sharedInstance].expensesDict objectForKey:[[NSNumber alloc] initWithInt:(int)(indexPath.section + 1)]];
        Expense * expenseToDelete = [expensesList objectAtIndex:indexPath.row];
        
        [[FetchHelper sharedInstance] deleteExpense:expenseToDelete withIndexPath:indexPath];
    }
}

#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {

    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JNExpenseDetailViewController *vc = [[JNExpenseDetailViewController alloc] init];
    
    int section, index;
    section = indexPath.section;
    index = indexPath.row; // where the expense object is within the array
    
    int expenseTypeID = section + 1;
    
    NSDictionary *expensesDict =[DataStoreSingleton sharedInstance].expensesDict;
    Expense * thisExpense = [[expensesDict objectForKey:[[NSNumber alloc] initWithInt:expenseTypeID]] objectAtIndex:index];
    Expense * clonedExpense = [thisExpense copy];
    
    vc.myExpense = clonedExpense;
    if (thisExpense.expenseID == 0){
        NSLog(@"Couldn't get the expense object");
    } else {
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
@end
