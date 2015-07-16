//
//  JunkSideMenuViewController.m
//  MFSideMenuDemoBasic
//
//  Created by Mark Pettersson on 2013-07-05.
//  Copyright (c) 2013 University of Wisconsin - Madison. All rights reserved.
//
#import "JunkSideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "JunkMapViewController.h"
#import "Route.h"
#import "JunkSideMenuCell.h"
#import "UIColor+ColorWithHex.h"
#import "JNStatusViewController.h"
#import "FranchiseListViewController.h"
#import "RouteListViewController.h"
#import "DataStoreSingleton.h"
#import "UserDefaultsSingleton.h"
#import "LoginViewController.h"
#import "MJCalendarViewController.h"
#import "MJExpensesTableViewController.h"
#import "MJEnvironmentalTableViewController.h"
#import "MJAdjustJobViewController.h"
#import "FetchHelper.h"
#import "Dispatch.h"
#import "AFHTTPRequestOperation.h"
#import "MJJobDetailViewController.h"
#import "SettingsViewController.h"
#import "OfflineLoginViewController.h"
#import "NoConnectionViewController.h"
#import "MJNotificationsTableViewController.h"
#import "Mode.h"

static const NSTimeInterval FETCH_JOBS_REFRESH_INTERVAL = 30;
//static const NSTimeInterval MINUTE = 60.0;
//static const NSTimeInterval POLLING_INTERVAL = 3 * MINUTE;

static const int NumMenusInSection0 = 7;

@implementation MenuInfo

- (instancetype)initMenu:(Class)viewClass withTitle:(NSString*)title withMenuTitle:(NSString*)menuTitle withMenuImageName:(NSString*)imageName
{
    if ( self = [super init] )
    {
        self.screenTitle = title;
        self.screenClass = viewClass;
        self.menuImageName = imageName;
        self.menuTitle = menuTitle;
    }
    
    return self;
}

@end


@interface JunkSideMenuViewController ()
{
    NSTimer *dispatchTimer;
    NSTimer *jobListRefreshTimer;
    UIAlertView *alert;
    NSArray *menus;
    int franchiseIndex_debug_testing;
    UIStoryboard *storyboardMain;
}

@end

@implementation JunkSideMenuViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    menus = [[NSArray alloc] initWithObjects:
               [[MenuInfo alloc] initMenu:[MJCalendarViewController class] withTitle:@"Job List" withMenuTitle:@"Jobs" withMenuImageName:@"jobs.png"],
               [[MenuInfo alloc] initMenu:[MJExpensesTableViewController class] withTitle:@"Expenses" withMenuTitle:@"Expenses" withMenuImageName:@"expenses.png"],
               [[MenuInfo alloc] initMenu:[MJEnvironmentalTableViewController class] withTitle:@"Environmental" withMenuTitle:@"Environmental" withMenuImageName:@"environment.png"],
               [[MenuInfo alloc] initMenu:[JunkMapViewController class] withTitle:@"Resource Map" withMenuTitle:@"Resource Map" withMenuImageName:@"resources.png"],
               [[MenuInfo alloc] initMenu:[FranchiseListViewController class] withTitle:@"Franchises" withMenuTitle:@"Franchise" withMenuImageName:@"franchise.png"],
               [[MenuInfo alloc] initMenu:[RouteListViewController class] withTitle:@"Routes" withMenuTitle:@"Route" withMenuImageName:@"route.png"],
               [[MenuInfo alloc] initMenu:[MJNotificationsTableViewController class] withTitle:@"NotificationTableVC" withMenuTitle:@"Dispatch History" withMenuImageName:@"icon-notification.png"],
             
               [[MenuInfo alloc] initMenu:[JNStatusViewController class] withTitle:@"Status" withMenuTitle:@"Status" withMenuImageName:@"status.png"],
               [[MenuInfo alloc] initMenu:nil withTitle:@"" withMenuTitle:@"Feedback" withMenuImageName:@"email.png"],
               [[MenuInfo alloc] initMenu:[SettingsViewController class] withTitle:@"Settings" withMenuTitle:@"Settings" withMenuImageName:@"gears_grey_large.png"],
               [[MenuInfo alloc] initMenu:nil withTitle:@"" withMenuTitle:@"Logout" withMenuImageName:@"logout.png"],
               nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processDispatches) name:@"FetchDispatchesComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDispatchAlerts) name:@"FetchJobListCompleteShowAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayJob) name:@"needToDisplayJob" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"DefaultFranchiseNameChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"DefaultRouteNameChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOut) name:@"LogoutRequest" object:nil];
    
    // Mode Transitioning Notifications
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionExpired) name:LOGGEDOUT_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected) name:DISCONNECTED_NOTIFICATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:LOGGEDIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterStandbyMode) name:STANDBY_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterActiveMode) name:ACTIVE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterOfflineMode) name:OFFLINE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterCachedMode) name:CACHED_NOTIFICATION object:nil];


    
    // initiate the notifications
    //dispatchTimer = [NSTimer scheduledTimerWithTimeInterval:POLLING_INTERVAL target:self selector:@selector(fetchDispatchesByRoute) userInfo:nil repeats:YES];
    
    jobListRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:FETCH_JOBS_REFRESH_INTERVAL target:self selector:@selector(fetchJobListForDefaultRouteAndCurrentDate) userInfo:nil repeats:YES];
    
    //[[FetchHelper sharedInstance] getAllCachingData];

    franchiseIndex_debug_testing = 0;
    //[self refreshResourcesList_debug_testing];
    
    storyboardMain = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float tableHeight = 484;
    
    if (screenSize.height <= 480.0f)
    {
        tableHeight = 460;
    }
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, tableHeight)];
}

- (void)refreshResourcesList_debug_testing
{
    [[FetchHelper sharedInstance] fetchResourcesALL:franchiseIndex_debug_testing++];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    dispatchTimer = nil;
    jobListRefreshTimer = nil;
    alert = nil;
    menus = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    @try
    {
        [self.tableView reloadData];
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_004" message:error exception:exception];
    }
}

- (void)fetchDispatchesByRoute
{
    [[FetchHelper sharedInstance] fetchDispatchesByRoute];
}

- (void)fetchJobListForDefaultRouteAndCurrentDate
{
    [[FetchHelper sharedInstance] fetchJobListForDefaultRouteAndCurrentDate];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    
    [headerView setBackgroundColor:[UIColor getJunkColorBackground]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, tableView.bounds.size.width - 10, 25)];
    label.text = (section == 0) ? @"Main" : @"Settings";
    label.textColor = [UIColor getJunkColorForeground];
    label.backgroundColor = [UIColor clearColor];

    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NumMenusInSection0;
    }
    else
    {
        return menus.count - NumMenusInSection0;
    }
}

- (NSString*)setMenuItem:(int)index forCell:(JunkSideMenuCell*)cell
{
    MenuInfo *info = [menus objectAtIndex:index];

    UIImage * myImage  = [[UIImage alloc] init];
    myImage = [UIImage imageNamed:info.menuImageName];
    [cell setImage2:myImage];
    cell.nameLabel.text = info.menuTitle;
    
    return info.menuTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JunkSideMenuCell";
    
    JunkSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JunkSideMenuCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    if (indexPath.section == 0)
    {
        NSString *menuTitle = [self setMenuItem:indexPath.row forCell:cell];

        if (indexPath.row == 4 )
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@: %@", menuTitle, [[UserDefaultsSingleton sharedInstance] getUserDefaultFranchiseName]];
        }
        else if (indexPath.row == 5)
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@: %@", menuTitle, [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteName]];
        }
    }
    else
    {
        [self setMenuItem:(indexPath.row + NumMenusInSection0) forCell:cell];
    }
    
    cell.nameLabel.textColor = [UIColor getJunkColorForeground];
    cell.nameLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)setViewController:(int)index
{
    UIViewController *vc = nil;
    
    MenuInfo *info = [menus objectAtIndex:index];
    if( [info.screenTitle isEqualToString:@"NotificationTableVC"] == YES )
    {
        vc = [storyboardMain instantiateViewControllerWithIdentifier:@"NotificationTableVC"];
    }
    else
    {
        vc = [[info.screenClass alloc] initWithNibName:NSStringFromClass(info.screenClass) bundle:nil];
        vc.title = info.screenTitle;
    }
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:vc];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 )
    {
        [self setViewController:indexPath.row];
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [self setViewController:indexPath.row + NumMenusInSection0];
        }
        if (indexPath.row == 1)
        {
            [self displayFeedback];
        }
        if (indexPath.row == 2)
        {
            [self setViewController:indexPath.row + NumMenusInSection0];
        }
        if (indexPath.row == 3)
        {
            [self displayLogout];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Login

- (void)displayFeedback
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSString *userName = [[UserDefaultsSingleton sharedInstance] getUserFullName];
        NSNumber *userID = [[UserDefaultsSingleton sharedInstance] getUserID];
        NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
        NSString *email = [[UserDefaultsSingleton sharedInstance] getFeedbackEmail];
        NSString *appVersion = [UserDefaultsSingleton appVersion];
        if (email)
        {
            [controller setToRecipients:@[email]];
        }
        else
        {
            [controller setToRecipients:@[@"junknetmobile@1800gotjunk.com"]];
        }
        [controller setSubject:@"Mobile App Feedback"];
        [controller setMessageBody:[NSString stringWithFormat:@"User Name: %@\nUserID: %ld\niOS Version: %@\nMobiJunk Version: %@\n",userName, (long)[userID integerValue], iosVersion, appVersion] isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"You need to set up your mail client before sending feedback" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        av.tag = -1;
        [av show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)displayLogout
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you want to logout?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Logout"
                                  otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void)logOut
{
    [[FetchHelper sharedInstance] clearChannels];
    
    [[FetchHelper sharedInstance] clearUsernamePassword];
    [[UserDefaultsSingleton sharedInstance] clearAllData];
    [[DataStoreSingleton sharedInstance] deleteAllData];

    [[UserDefaultsSingleton sharedInstance] storeOfflineKey:@""];
    
    [DataStoreSingleton sharedInstance].isUserLoggedIn = NO;

    [self showLoginScreen];
}


// this gets fired after the list of dispatches gets retrieved for the current route
- (void)processDispatches
{
    // get the list of all dispatches sent out today
    NSMutableArray* dispatchesList = [[DataStoreSingleton sharedInstance] dispatchesList];
    
    UserDefaultsSingleton *userDefaults = [UserDefaultsSingleton sharedInstance];
    
    if (dispatchesList && dispatchesList.count > 0)
    {
        // filter out the dispatches that user has already acknowledged
        
        for (int i=0; i<dispatchesList.count; i++){
            Dispatch * dispatch = [dispatchesList objectAtIndex:i];
            
            // move onto the next dispatch because this one has already been acknowledged
            if ([userDefaults didUserAcknowledgeDispatch:[[NSNumber alloc] initWithInt:dispatch.dispatchID]])
            {
                [dispatchesList removeObject:dispatch];
                i--;
                continue;
            }
        }
        
        // do we have any dispatches remaining that we still need to alert to the user?
        // if so, then let's make a call to refresh the jobs list
        
        [DataStoreSingleton sharedInstance].dispatchesList = dispatchesList;
        
        if (dispatchesList && dispatchesList.count > 0){
            NSNumber * routeID;
            
            if ([DataStoreSingleton sharedInstance].currentRoute)
            {
                routeID = [DataStoreSingleton sharedInstance].currentRoute.routeID;
            }
            else
            {
                routeID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
            }
            
            [[FetchHelper sharedInstance] fetchJobListForRoute:routeID andDate:[NSDate date] withAlert:YES];
        }
    }
}

// this gets fired after the jobs list gets refreshed
- (void)showDispatchAlerts
{
    NSMutableArray *dispatchesList = [DataStoreSingleton sharedInstance].dispatchesList;
    
    for (Dispatch * dispatch in dispatchesList)
    {
        NSString * alertBody = [NSString stringWithFormat:@"%@: JobID %d", dispatch.dispatchMode, dispatch.jobID];
        Job * job;
        
        // look up the dispatch's job from the list of jobs on the schedule
        NSArray * jobsList = [DataStoreSingleton sharedInstance].jobList;
        if (jobsList && jobsList.count > 0)
        {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"jobID = %d", dispatch.jobID]] ;
            
            NSArray * searchResults = [jobsList filteredArrayUsingPredicate:predicate];
            if (searchResults && searchResults.count > 0)
            {
                job = ((Job *)([searchResults objectAtIndex:0]));
                
            }
        }
        
        UIAlertView * av;
        
        if (!job || [dispatch.dispatchMode isEqualToString:@"Cancel"])
        { // hide the "view details" option for any job that's no longer on the schedule
            av = [[UIAlertView alloc] initWithTitle:@"Dispatch" message:alertBody delegate:self cancelButtonTitle:@"Snooze" otherButtonTitles: @"OK", nil];
        }
        else
        {
            av = [[UIAlertView alloc] initWithTitle:@"Dispatch" message:alertBody delegate:self cancelButtonTitle:@"Snooze" otherButtonTitles: @"OK", @"View Details", nil];
        }
        
        // store dispatchID and jobID for the job represented by this alertview
        av.tag = dispatch.dispatchID;
        av.accessibilityLabel = [NSString stringWithFormat:@"%d", dispatch.jobID];
        [av show];
    }
}

#pragma mark - UIAlertView delegate methods

// handle the button clicking for the dispatch alertviews
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( alertView.tag < 0 )
    {
        alert = nil;
        return;
    }
    
    int dispatchID = alertView.tag;
    int jobID = [alertView.accessibilityLabel intValue];
    
    switch(buttonIndex)
    {
        case 1:
        { // OK
            UserDefaultsSingleton *userDefaults = [UserDefaultsSingleton sharedInstance];
            
            [userDefaults setUserAcknowledgedDispatch:[[NSNumber alloc] initWithInt:dispatchID]];
            
            break;
        }
        case 2:
        { // View Details (this button would be hidden if dealing with cancelled jobs)
            
            Job * job;
            
            // Do the acknowledgment
            UserDefaultsSingleton *userDefaults = [UserDefaultsSingleton sharedInstance];
            [userDefaults setUserAcknowledgedDispatch:[[NSNumber alloc] initWithInt:dispatchID]];
            
            [[FetchHelper sharedInstance] setDispatchStatus:dispatchID];
            
            // Go into the job list and retrieve matching job object
            NSArray * jobsList = [DataStoreSingleton sharedInstance].jobList;
            
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"jobID = %d", jobID];
            NSArray * searchResults = [jobsList filteredArrayUsingPredicate:predicate];
            
            // Go into the job details screen if we were able to find the job.
            if (searchResults && searchResults.count > 0)
            {
                job = [searchResults objectAtIndex:0];
                
                MJJobDetailViewController * demoController = [[MJJobDetailViewController alloc] initWithJob:job];
                demoController.title = [NSString stringWithFormat:@"%d", jobID];
                
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                [navigationController pushViewController:demoController animated:YES];
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            }
            
            break;
        }
        default: // Snooze
            // do nothing; the local notification should appear again during the next 5 minutes
            break;
    }
    
    alert = nil;
}

-(void)displayJob
{
    NSString *jobToView = [[UserDefaultsSingleton sharedInstance] getJobToView];
    if (jobToView)
    {
        if ([jobToView length] > 1)
        {
            MJJobDetailViewController *vc = [[MJJobDetailViewController alloc] initWithJob:[DataStoreSingleton sharedInstance].pushJob];
            
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            [[[navigationController.viewControllers objectAtIndex:0] navigationController] pushViewController:vc animated:YES];
            
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

            [[UserDefaultsSingleton sharedInstance] setJobToView:@""];
        }
        else
        {
            NSLog(@"there is no job to display");
        }
    }
}

# pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1 && buttonIndex == 0)
    {
        [self logOut];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)transitionToOfflinMode
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self showOfflineScreen];
    }];
}

- (void)showOfflineScreen
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    OfflineLoginViewController *vc = [[OfflineLoginViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        NSLog(@"Offline View Launched.");
    }];
}

- (void)showLoginScreen
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)disconnected
{
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //NoConnectionViewController *noc = [[NoConnectionViewController alloc] init];
    //[self presentViewController:noc animated:YES completion:nil];
    
    // In the case of no internet, Enter offline mode.
    [self enterOfflineMode];

}

- (void)enterOfflineMode
{
    
    UIViewController *pvc = self.presentedViewController;
    if([pvc isKindOfClass:[LoginViewController  class]]){
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"LoginViewContrller dismissed");
            [self enterOfflineMode];
        }];
    }
    
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if( [[UserDefaultsSingleton sharedInstance] isOfflineAuthorized] == NO )
    {
        [self showOfflineScreen];
        
        return;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedServerAlreadyDown" object:nil];
        
        if (alert == nil)
        {
            alert = [[UIAlertView alloc] initWithTitle:@"The JunkNet server is currently unreachable.  All data is cached and may not reflect recent changes." message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            alert.tag = -1;
            [alert show];
        }
    }
}

- (void)enterStandbyMode
{
    /*
    if( self.menuContainerViewController == nil )
    {
        return;
    }
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    if( navigationController == nil || navigationController.viewControllers.count == 0 )
    {
        return;
    }
    
    NSLog(@"Session Expired, Show Login Screen");
    [self showLoginScreen];
    
    if( [[UserDefaultsSingleton sharedInstance] isFirstTimeInstall] == YES )
    {
        return;
    }
    
    if (alert == nil)
    {
        alert= [[UIAlertView alloc] initWithTitle:@"Your Login has expired. Please login again" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        alert.tag = -1;
        [alert show];
    }
    */
    
    UIViewController *pvc = self.presentedViewController;
    if([pvc isKindOfClass:[OfflineLoginViewController class]]){
        // We are transitioning from Offline Mode
        // Dismiss Offline Login View Controller first
        [self dismissViewControllerAnimated:YES completion:^{
            [self showLoginScreen];
        }];
    }else{
        // We are transitioning from Active Mode
        // Display Login Screen
        [self showLoginScreen];
    
    }
    
}

-(void)enterActiveMode
{
    // We can only enter Active Mode thru Standby Mode or Cached Mode.
    // If we are in Standby Mode, we need to lift the login screen.
    UIViewController *pvc = self.presentedViewController;
    if([pvc isKindOfClass:[LoginViewController class]]){
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"LoginViewContrller dismissed");
        }];
    }
}

-(void)enterCachedMode
{
    NSLog(@"Enter Cached Mode");
}



- (void)refreshTable
{
    [self.tableView reloadData];
}

@end
