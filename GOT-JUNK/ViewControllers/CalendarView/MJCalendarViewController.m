//
//  MJCalendarViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJCalendarViewController.h"
#import "DataStoreSingleton.h"
#import "Job.h"
#import "MJJobCell.h"
#import "MJJobDetailViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "MSGridline.h"
#import "DateHelper.h"
#import "UserDefaultsSingleton.h"
#import "FetchHelper.h"
#import "Route.h"
#import "MSTimeRowHeader.h"
#import "MJTimeIndicator.h"
#import "MBProgressHUD.h"
#import "Flurry.h"
//#import "MJNotificationsTableViewController.h"

@interface MJCalendarViewController ()
{
    Job *_alertJob;
    NSDictionary *_jobsShowedAlert;
    BOOL _isAlertShowing;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSArray *jobList;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIAlertView *av;
@property (weak, nonatomic) IBOutlet UIButton *timestampDisplay;

@end

@implementation MJCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _jobsShowedAlert = nil;
    _alertJob = nil;
    self.currentDate = nil;
    self.jobList = nil;
    self.refreshControl = nil;
    self.av = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    @try
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshJobList) name:@"FetchJobListComplete" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshJobListAndShowAlert) name:@"FetchJobListCompleteShowAlert" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefresh) name:@"MustRefreshJobsList" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnected) name:DISCONNECTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFailedServerAlreadyDown) name:@"FetchFailedServerAlreadyDown" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataReady) name:COREDATAREADY_NOTIFICATION object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnected) name:RECONNECTED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimeStamp) name:JOBSTIMESTAMPUPDATE_NOTIFICATION object:nil];
        
        MJCollectionViewCalendarLayout *automationLayout = (MJCollectionViewCalendarLayout *)self.collectionView.collectionViewLayout;
        [automationLayout registerClass:[MSGridline class]  forDecorationViewOfKind:@"MSGridLine"];
        [automationLayout registerClass:[MSTimeRowHeader class]  forDecorationViewOfKind:@"MSTimeRowHeader"];
        [self.collectionView registerClass:MJTimeIndicator.class forSupplementaryViewOfKind:@"MJTimeIndicator" withReuseIdentifier:@"MJTimeIndicator"];
        [self.collectionView registerNib:[UINib nibWithNibName:@"MJJobCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:@"MJJobCell"];

        [self setupMenuBarButtonItems];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(startRefresh)
                      forControlEvents:UIControlEventValueChanged];
        self.refreshControl.tintColor = [UIColor blueColor];
        [self.collectionView addSubview:self.refreshControl];
        
        self.currentDate = [DateHelper now];
        [DataStoreSingleton sharedInstance].currentDate = self.currentDate;
        self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
        
        self.title = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteName];
        
        
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_005" message:error exception:exception];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    @try
    {
        if ( ([DataStoreSingleton sharedInstance].jobList && [[DataStoreSingleton sharedInstance].jobList count] > 0 )
            || ![DataStoreSingleton sharedInstance].isConnected )
        {
            self.jobList = [DataStoreSingleton sharedInstance].jobList;
            [self sortArray];
        }
        else
        {
            [self getJobListForCurrentRoute];
        }
        
        [self updateTimeStamp];

    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_006" message:error exception:exception];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString* tempPermissions =  [UserDefaultsSingleton sharedInstance].getUserPermissions;
    
    if ( [tempPermissions isEqualToString:@"Truck Team Member"])
    {
        self.prevButton.hidden = YES;
        self.prevButton1.hidden = YES;
        self.nextButton.hidden = YES;
        self.nextButton1.hidden = YES;
        [self setButtonState:NO];
    }
    else
    {
        self.prevButton.hidden = NO;
        self.prevButton1.hidden = NO;
        self.nextButton.hidden = NO;
        self.nextButton1.hidden = NO;
        [self updateState];
    }
}



#pragma mark - UIBarButtonItem Callbacks

- (void)setupMenuBarButtonItems
{
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItemRefresh];
    
    //NSArray *items = [NSArray arrayWithObjects:[self rightMenuBarButtonItemRefresh], [self rightMenuBarButtonItemHistory], nil];
    //[self.navigationItem setRightBarButtonItems:items animated:NO];
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed && ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self])
    {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItemRefresh
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"UIButtonBarRefresh.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItemHistory
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"icon-arrow-alert.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(rightSideMenuButtonHistoryPressed:)];
}


- (UIBarButtonItem *)backBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^
     {
        [self setupMenuBarButtonItems];
     }];
}

- (void)setButtonState:(BOOL)enabled
{
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
    [self.nextButton1 setEnabled:enabled];
    [self.nextButton setEnabled:enabled];
    [self.prevButton1 setEnabled:enabled];
    [self.prevButton setEnabled:enabled];
}


- (void)updateState
{
    //[self setButtonState:[DataStoreSingleton sharedInstance].isConnected];
}

- (void)reconnected
{
    [self setButtonState:YES];

}

- (void)disconnected
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    //[self setButtonState:NO];

    
    [self showContent];
}

-(void)coreDataReady
{
    // Core Data is ready, we are disconnected and jobList is empty.  Get from cache.
    if(!self.jobList && ![DataStoreSingleton sharedInstance].isConnected){
        self.jobList = [DataStoreSingleton sharedInstance].jobList;
        [self sortArray];
    }
}

- (void)fetchFailedServerAlreadyDown
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //[self setButtonState:NO];
    
    [self showContent];
}

- (IBAction)scrollTo:(id)sender
{
    NSInteger target_idx = 0;
    NSIndexPath *item_idx = [NSIndexPath indexPathForItem:target_idx inSection:1];
    [self.collectionView scrollToItemAtIndexPath:item_idx atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)hideContent
{
    [self.noDataLabel setHidden:YES];
    [self.collectionView setHidden:YES];
}

- (IBAction)nextWasPressed:(id)sender
{
    if(![DataStoreSingleton sharedInstance].isConnected){
        _currentDate = [DateHelper tomorrow:_currentDate];
        [DataStoreSingleton sharedInstance].currentDate = _currentDate;
        [self refreshJobList];
    }else{
        [self getJobListForRoute:YES];
    }
    
    if (self.currentDate)
    {
        self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
    }
}

- (IBAction)previousWasPressed:(id)sender
{
    if(![DataStoreSingleton sharedInstance].isConnected){
        _currentDate = [DateHelper yesterday:_currentDate];
        [DataStoreSingleton sharedInstance].currentDate = _currentDate;
        [self refreshJobList];
    }else{
        [self getJobListForRoute:NO];
    }
    
    if (self.currentDate)
    {
        self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
    }
}

-(void)startRefresh
{
    [self getJobListForCurrentRoute];
    [self.refreshControl endRefreshing];
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray new];
    
    NSIndexPath *decorationIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    UICollectionViewLayoutAttributes *decorationAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"MSTimeRowHeader" withIndexPath:decorationIndexPath];
    decorationAttributes.frame = CGRectMake(0.0f,
                                            0.0f,
                                            200,
                                            200);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    layoutAttributes.zIndex = -10;
    return layoutAttributes;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Job* job = [self.jobList objectAtIndex:indexPath.section];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:job.jobDuration];
    int i = [myNumber integerValue]/30;
    CGSize retval = CGSizeMake(240, 80* i-1);
    retval.height += 0; retval.width += 30; return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    Job* job = [self.jobList objectAtIndex:section];
    if ([self.jobList count] > section + 1)
    {
        Job* job2 = [self.jobList objectAtIndex:section+1];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        NSNumber * myNumber = [f numberFromString:job2.jobDuration];
        NSNumber * myNumber2 = [f numberFromString:job.jobDuration];
        float spaceNumber = [myNumber integerValue] - [myNumber2 integerValue];
        NSDate * firstDate = job.jobDate;
        NSDate * secondDate = job2.jobDate;
        NSTimeInterval diff = [secondDate timeIntervalSinceDate:firstDate];    //dateToApiString:(NSDate *)date
        NSInteger time = diff;
        spaceNumber = time;
        spaceNumber = spaceNumber /60;
        spaceNumber= spaceNumber-[myNumber2 integerValue];
        spaceNumber = abs(spaceNumber);
        spaceNumber = spaceNumber * 2.66666;
        return UIEdgeInsetsMake(0, 25, spaceNumber+1, 0);
    }
    return UIEdgeInsetsMake(0, 25, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Job *selectedJob = [self.jobList objectAtIndex:indexPath.section];
    
    if (![selectedJob isBookoff])
    {
        MJJobDetailViewController *vc = [[MJJobDetailViewController alloc] initWithJob:selectedJob];
        vc.indexJob = indexPath.section;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Deselect item
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return [self.jobList count];
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MJJobCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MJJobCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.job = [self.jobList objectAtIndex:indexPath.section];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if ([kind isEqualToString:@"MJTimeIndicator"])
    {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MJTimeIndicator" forIndexPath:indexPath];
        [timeRowHeader setTime:@"hello"];
        view = timeRowHeader;
    }
    return view;
}

# pragma mark - Job list Methods

- (void)getJobListForCurrentRoute
{
    if ([[UserDefaultsSingleton sharedInstance] didUserLogout] == YES)
    {
        [DataStoreSingleton sharedInstance].isUserLoggedIn = NO;
        [DataStoreSingleton sharedInstance].debugDisplayText1 = @"getJobListForCurrentRoute";
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:LOGGEDOUT_NOTIFICATION object:nil];
    
        return;
    }
  
    if (![DataStoreSingleton sharedInstance].isConnected )
    {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self hideContent];
    
    if ([DataStoreSingleton sharedInstance].currentRoute)
    {
        NSNumber *rID = [DataStoreSingleton sharedInstance].currentRoute.routeID;
        [[FetchHelper sharedInstance] fetchExpensesByRoute:[rID intValue] onDate:self.currentDate];
        [[FetchHelper sharedInstance] fetchEnviroByRoute:[rID intValue] onDate:self.currentDate];
        
        [[FetchHelper sharedInstance] fetchJobListForRoute:rID andDate:self.currentDate withAlert:NO];
    }
    else
    {
        NSNumber *defaultRouteID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
        [[FetchHelper sharedInstance] fetchJobListForRoute:defaultRouteID andDate:self.currentDate withAlert:NO];
    }
}

- (void)getJobListForRoute:(BOOL)tomorrow
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self hideContent];
    
    if( tomorrow == YES )
    {
        _currentDate = [DateHelper tomorrow:_currentDate];
    }
    else
    {
        _currentDate = [DateHelper yesterday:_currentDate];
    }
    
    [DataStoreSingleton sharedInstance].currentDate = _currentDate;
    if ([DataStoreSingleton sharedInstance].currentRoute)
    {
        [[FetchHelper sharedInstance] fetchJobListForRoute:[DataStoreSingleton sharedInstance].currentRoute.routeID andDate:_currentDate withAlert:NO];
    }
    else
    {
        NSNumber *defaultRouteID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
        [[FetchHelper sharedInstance] fetchJobListForRoute:defaultRouteID andDate:_currentDate withAlert:NO];
    }
}

- (void)rightSideMenuButtonPressed:(id)sender
{
    [self startRefresh];
}

- (void)refreshJobListAndShowAlert
{
    [self.refreshControl endRefreshing];
    self.jobList = [DataStoreSingleton sharedInstance].jobList;
    [self sortArray];

    [self scheduleLocalAlarms];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _isAlertShowing = NO;
    
    if (buttonIndex == 1)
    {
        Job *selectedJob = _alertJob;
        
        MJJobDetailViewController *vc = [[MJJobDetailViewController alloc] initWithJob:selectedJob];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
        for (Job *j in self.jobList)
        {
            if (!j.dispatchAccepted && !(j == _alertJob) && !([_jobsShowedAlert objectForKey:[NSString stringWithFormat:@"%d", [j.jobID integerValue]]]) && !_isAlertShowing)
            {
                //only show an alert for one unconfirmed job
                _alertJob = j;
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_jobsShowedAlert];
                [dict setObject:j forKey:[NSString stringWithFormat:@"%d", [j.jobID integerValue]]];
                _jobsShowedAlert = dict;
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"New Job: %@", j.clientName] message:j.dispatchMessage delegate:self cancelButtonTitle:@"Snooze" otherButtonTitles:@"View Details", nil];
                [av show];
                _isAlertShowing = YES;
                break;
            }
        }
    }
    self.av = nil;
}


- (void)refreshJobList
{
    self.jobList = [DataStoreSingleton sharedInstance].jobList;
    [self sortArray];
    [self scheduleLocalAlarms];
    if ([self.jobList count] > 0)
    {
        Job* thisJob = [self.jobList objectAtIndex:0];
        NSNumber* i = thisJob.jobStartTimeOriginal;
        int  j = [i integerValue]%60;
        [MSTimeRowHeader coordinate:[i integerValue]/60 andMinutes:j];
        [MJTimeIndicator coordinate:[i integerValue]/60 andMinutes:j];
    }
    
    self.title = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteName];
}

# pragma mark - Alarm Methods

- (void)scheduleLocalAlarms
{
    if ([DataStoreSingleton sharedInstance].minutesTilAlert)
    {
        [self cancelLocalAlarms];
        
        for (Job *j in self.jobList)
        {
            if ([j.clientName length] > 1 )
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                NSString *newDate = [NSString stringWithFormat:@"%@-%@", j.jobDate, j.jobStartTime];
                NSLog(@"new date: %@", newDate);
                [formatter setDateFormat:@"yyyyMMdd-HH:mm"];
                NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@", j.jobDate, j.jobStartTime]];
                UILocalNotification *notif = [[UILocalNotification alloc] init];
                notif.alertBody = [NSString stringWithFormat:@"Job for %@ is in 30 minutes.", j.clientName];
                notif.fireDate = [date dateByAddingTimeInterval:-1800];
                notif.soundName = @"update.caf";
                NSLog(@"new date: %@", [formatter stringFromDate:notif.fireDate]);
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
        }
    }
    else
    {
        [self cancelLocalAlarms];
        
        //   TFLog(@"Should be scheduling real job alarms");
        
        for (Job *j in self.jobList)
        {
            //  TFLog(@"Formatting dates for alarm and job: %@", j.clientName);
            if (j.clientName
                ) {
            NSDate *date = [NSDate date];
            NSDate *jobDate = [j.jobDate dateByAddingTimeInterval:-1800];
            
            //   TFLog(@"CurrentDate: %@, 30MinutesbeforeJob: %@", date, jobDate);
            
            if ([date  earlierDate:jobDate] == date) {
                UILocalNotification *notif = [[UILocalNotification alloc] init];
                notif.alertBody = [NSString stringWithFormat:@"Job for %@ is in 30 minutes.", j.clientName];
                notif.fireDate = jobDate;
                notif.soundName = @"update.caf";
                NSLog(@"alarm date: %@", notif.fireDate);
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
            }
        }
    }
}


-(void)sortArray
{
    if ([self.jobList count] > 0)
    {
        self.jobList = [DataStoreSingleton sharedInstance].jobList;
        self.dateLabel.text = [DateHelper dateToJobListString:[(Job*)[self.jobList objectAtIndex:0] jobDate]];

        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobDate" ascending:YES];
        NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray * sortedArray = [self.jobList sortedArrayUsingDescriptors:descriptors];
        self.jobList = sortedArray;
        Job *newJob = [[Job alloc] init];
        newJob.jobDuration = @"0";
        newJob.jobStartTime = @"300";
        newJob.jobStartTimeOriginal = [(Job*)[self.jobList objectAtIndex:0] jobStartTimeOriginal];
        newJob.jobStartTimeOriginal = [NSNumber numberWithInt:[newJob.jobStartTimeOriginal integerValue] - 60 ];
        NSDate *theDate =  [(Job*)[self.jobList objectAtIndex:0] jobDate];
        newJob.jobDate = [theDate dateByAddingTimeInterval:-3600];
        Job *newJob1 = [[Job alloc] init];
        newJob1.jobDuration = @"0";
        newJob1.jobStartTime = @"300";
        newJob1.jobStartTimeOriginal = [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobStartTimeOriginal];
        int intDuration = [[NSString stringWithFormat:@"%@",  [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobDuration]] intValue];
        
        newJob1.jobStartTimeOriginal = [NSNumber numberWithInt:[newJob1.jobStartTimeOriginal integerValue] + 60 + intDuration];
        NSDate *theDate1 = [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobDate];
        newJob1.jobDate = [theDate1 dateByAddingTimeInterval:3600*2];
        NSMutableArray * tempArray = [NSMutableArray arrayWithArray:self.jobList];
        [tempArray addObject:newJob1];
        [tempArray addObject:newJob];
        
        NSArray * sortedArray1 = [tempArray sortedArrayUsingDescriptors:descriptors];
        self.jobList = sortedArray1;
        if ([self.jobList count] > 0)
        {
            Job* thisJob = [sortedArray1 objectAtIndex:0];
            NSNumber* i = thisJob.jobStartTimeOriginal;
            int  j = [i integerValue]%60;
            [MSTimeRowHeader coordinate:[i integerValue]/60 andMinutes:j];
            [MJTimeIndicator coordinate:[i integerValue]/60 andMinutes:j];

        }
    }

    [self.collectionView reloadData];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self showContent];
}

- (void)showContent
{
    if ([self.jobList count] < 1)
    {
        self.noDataLabel.hidden = NO;
        self.collectionView.hidden = YES;
    }
    else
    {
        self.noDataLabel.hidden = YES;
        self.collectionView.hidden = NO;
    }

}
- (void)cancelLocalAlarms
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)rightSideMenuButtonHistoryPressed:(id)sender
{
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

//    MJNotificationsTableViewController* vc = [sb instantiateViewControllerWithIdentifier:@"NotificationTableVC"];
    
//    MJNotificationsTableViewController *vc = [[MJNotificationsTableViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Helper Methods

-(void)updateTimeStamp
{
    NSString * strTime = [self stringFromTimeStamp: [DataStoreSingleton sharedInstance].jobsLastUpdateTime];
    [self.timestampDisplay setTitle:strTime forState:UIControlStateNormal];
}

-(NSString*)stringFromTimeStamp:(NSDate *)timeStamp
{
    NSString *result = @"";
    if(timeStamp){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, hh:mm a"];
        result = [NSString stringWithFormat:@"Last Update: %@", [formatter stringFromDate:timeStamp]];
    }
    return result;
}


@end
