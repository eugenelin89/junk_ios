//
//  RouteListViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "RouteListViewController.h"
#import "DataStoreSingleton.h"
#import "Route.h"
#import "UserDefaultsSingleton.h"
#import "MFSideMenuContainerViewController.h"
#import "FetchHelper.h"
#import "UserDefaultsSingleton.h"
#import "MJCalendarViewController.h"

@interface RouteListViewController ()
{
    BOOL requiresBackAfterSelection;
}
@end

@implementation RouteListViewController

@synthesize routeList = _routeList;
@synthesize routeListTableView = _routeListTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRouteList) name:@"FetchRouteListComplete" object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFailedNoInternet) name:@"FetchTestFailed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchInternetUp) name:@"FetchTestSuccess" object:nil];
    
        [DataStoreSingleton sharedInstance].filterRoute = nil;
        requiresBackAfterSelection = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DataStoreSingleton sharedInstance].filterRoute = nil;
    
    self.view.backgroundColor = [UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [DataStoreSingleton sharedInstance].filterRoute = nil;
    
    NSString *permis = [DataStoreSingleton sharedInstance].permissions;
    if ( [permis isEqualToString:@"Truck Team Member"])
    {
        self.routeList = [DataStoreSingleton sharedInstance].assignedRoutes;
        [self.routeListTableView reloadData];
    }
    else
    {
        if ([DataStoreSingleton sharedInstance].routeList && [[DataStoreSingleton sharedInstance].routeList count] > 0 && [[DataStoreSingleton sharedInstance] isOffline] )
        {
            self.routeList = [DataStoreSingleton sharedInstance].routeList;
            [self.routeListTableView reloadData];
        }
        else
        {
            [self getRouteList];
        }
    }
    
    if( [DataStoreSingleton sharedInstance].isInternetLive == NO || [DataStoreSingleton sharedInstance].isJunkNetLive == NO )
    {
        [self fetchFailedNoInternet];
    }
    
    self.title = [[UserDefaultsSingleton sharedInstance] getUserDefaultFranchiseName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRequiresBack:(BOOL)requiresBack
{
    requiresBackAfterSelection = requiresBack;
}

- (void)fetchInternetUp
{
    [self setButtonState:YES];
}

- (void)fetchFailedNoInternet
{
    [self setButtonState:NO];
}

- (void)setButtonState:(BOOL)enabled
{
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int addition = 0;
    if( requiresBackAfterSelection == YES )
    {
        addition = 1;
    }
    return [self.routeList count] + addition;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  
    int row = indexPath.row;
    
    if( requiresBackAfterSelection == YES )
    {
        if( row == 0 )
        {
            cell.textLabel.text = @"All Routes";
            cell.accessoryType = UITableViewCellAccessoryNone;

            return cell;
        }
        else
        {
            row--;
        }
    }
    
    //Route *route = [self.routeList objectAtIndex:indexPath.row];
    Route *route = [self.routeList objectAtIndex:row];
    cell.textLabel.text = requiresBackAfterSelection ? [NSString stringWithFormat:@"%@",route.routeName] : [NSString stringWithFormat:@"%@: %@ Jobs",route.routeName, route.jobsInRoute]  ;
    cell.accessoryType = requiresBackAfterSelection ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
  
    return cell;
}

# pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( requiresBackAfterSelection == NO )
    {
        Route *route = [self.routeList objectAtIndex:indexPath.row];
        [DataStoreSingleton sharedInstance].currentRoute = route;
        [DataStoreSingleton sharedInstance].enviroDict = nil;
        
        NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
        
        // empty out the list of expenses
        [DataStoreSingleton sharedInstance].expensesDict = nil;
        
        if( [[DataStoreSingleton sharedInstance] isOffline] )
        {
            // get the joblist from the currentRoute
            [[DataStoreSingleton sharedInstance] getJobListForCachedCurrentRoute];
        }
        else
        {
            // load up the jobs for this chosen route, but block until complete
            [[FetchHelper sharedInstance] fetchJobListForRoute:route.routeID andDate:currentDate withAlert:NO];
        }
        
        UserDefaultsSingleton *defaults =[UserDefaultsSingleton sharedInstance];

        [defaults setUserDefaultRouteID:route.routeID];
        [defaults setUserDefaultRouteName:route.routeName];
        
        MJCalendarViewController *calViewController = [[MJCalendarViewController alloc] initWithNibName:@"MJCalendarViewController" bundle:nil];
        calViewController.title = @"Job List";
        
        NSArray *controllers = [NSArray arrayWithObject:calViewController];
        self.navigationController.viewControllers = controllers;
    }
    else
    {
        if( indexPath.row == 0 )
        {
            [DataStoreSingleton sharedInstance].filterRoute = nil;
        }
        else
        {
            Route *route = [self.routeList objectAtIndex:indexPath.row - 1];
            [DataStoreSingleton sharedInstance].currentRoute = route;
            [DataStoreSingleton sharedInstance].enviroDict = nil;
        
            [DataStoreSingleton sharedInstance].filterRoute = route;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

# pragma mark - GET Route List

- (void)getRouteList
{
    [[FetchHelper sharedInstance] fetchRouteList];
}

- (void)refreshRouteList
{
    self.routeList = [DataStoreSingleton sharedInstance].routeList;
    [self.routeListTableView reloadData];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

#pragma mark - UIBarButtonItems

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"UIButtonBarRefresh.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(getRouteList)];
}

#pragma mark - UIBarButtonItem Callbacks

- (void)rightSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{}];
}

@end
