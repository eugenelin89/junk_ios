//
//  MJCopyMoveViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-16.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJCopyMoveViewController.h"
#import "MJAdjustJobViewController.h"
#import "MJJobDetailViewCell.h"
#import "UIColor+ColorWithHex.h"
#import "JunkSideMenuCell.h"
#import "Job.h"
#import "DataStoreSingleton.h"
#import "MFSideMenuContainerViewController.h"
#import "MJJobCell.h"
#import "MBProgressHUD.h"
#import "FetchHelper.h"
#import "UserDefaultsSingleton.h"
#import "DateHelper.h"
#import "Route.h"
#import "MSGridline.h"
#import "RouteListViewController.h"
#import "MSTimeRowHeader.h"
#import "LookupTableViewController.h"
#import "CopyMoveRouteViewController.h"
#import "Flurry.h"
#import "MJTimeIndicator.h"

@interface MJCopyMoveViewController ()
{
    BOOL needsMove;
    BOOL needsDuration;
}

@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end


@implementation MJCopyMoveViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobSuccessful) name:@"UpdateJobSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobFailed) name:@"UpdateJobFailed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyMoveJobSuccessful) name:@"CopyMoveJobSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyMoveJobFailed) name:@"CopyMoveJobFailed" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshJobList) name:@"FetchJobListComplete" object:nil];
        needsMove = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MustRefreshJobsList" object:nil];
        [self.collectionView registerNib:[UINib nibWithNibName:@"MJJobCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:@"MJJobCell"];
    [self.collectionView registerClass:MJTimeIndicator.class forSupplementaryViewOfKind:@"MJTimeIndicator" withReuseIdentifier:@"MJTimeIndicator"];
    MJCollectionViewCalendarLayout *automationLayout = (MJCollectionViewCalendarLayout *)self.collectionView.collectionViewLayout;
    [automationLayout registerClass:[MSGridline class]  forDecorationViewOfKind:@"MSGridLine"];
    [automationLayout registerClass:[MSTimeRowHeader class]  forDecorationViewOfKind:@"MSTimeRowHeader"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.title = [NSString stringWithFormat:@"%@", self.currentJob.jobID];
    self.jobList = [DataStoreSingleton sharedInstance].jobList;
    self.currentDate = [DataStoreSingleton sharedInstance].currentDate;
    [self sortArray];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    // Do any additional setup after loading the view from its nib.
    [self setupMenuBarButtonItems];
    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    self.customerNameLabel.textColor = col2;
    self.customerNameLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    self.startTimeLabel.textColor = col2;
    self.customerNameLabel.text = self.currentJob.clientName;
    self.customerCompanyLabel.text = self.currentJob.clientCompany;
    self.tempJobDuration = self.currentJob.jobDuration;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@", self.currentJob.jobStartTime];
    NSArray *timeArray = [self.currentJob.jobEndTime componentsSeparatedByString:@":"];
    NSArray *timeArray2 = [self.currentJob.jobStartTime componentsSeparatedByString:@":"];
    self.hour = [[timeArray objectAtIndex:0] intValue];
    self.mins = [[timeArray objectAtIndex:1] intValue];
    self.hourStart = [[timeArray2 objectAtIndex:0] intValue];
    self.minsStart = [[timeArray2 objectAtIndex:1] intValue];
    [self updateTimeLabel];
    if (self.originalDuration == 0)
        self.originalDuration = [self.currentJob.jobDuration integerValue];
    self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
    [self.uiSwitch setOn:NO];
    self.copiedJob = [[Job alloc]init];
    self.copiedJob.jobID = @99;
    self.copiedJob.clientName = self.currentJob.clientName;
    self.copiedJob.jobDuration = self.currentJob.jobDuration;
    self.copiedJob.jobStartTime = self.currentJob.jobDuration;
    self.copiedJob.jobType = self.currentJob.jobType;
    self.copiedJob.jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    self.copiedJob.jobStartTime = self.currentJob.jobStartTime;
    self.copiedJob.jobDate = self.currentJob.jobDate;
    self.copiedJob.jobEndTime = self.currentJob.jobEndTime;
    self.copiedJob.clientCompany = self.currentJob.clientCompany;
    [self loadCurrentJob];
    //[self.collectionView reloadData];
    [self.tableView reloadData];
    [self sortArray];

    int h = self.view.frame.size.height - self.collectionView.frame.origin.y - 60;
    [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x, self.collectionView.frame.origin.y, self.collectionView.frame.size.width, h)];
}

- (Job *)currentJob;
{
    if (!_currentJob)
    {
        _currentJob = [[Job alloc] init];
    }
    return _currentJob;
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

- (IBAction)copyButton:(id)sender
{
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    self.isRed = NO;
    [self sortArray];
    [self viewDidLoad];
    if ([self.uiSwitch isOn])
        self.startLabel.text = @"Make a copy";
    else
        self.startLabel.text = @"Move job";
    
}
-(void)loadCurrentJob
{
    self.title = [NSString stringWithFormat:@"%@", self.currentJob.jobID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MJJobCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:@"MJJobCell"];
    [self sortArray];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    // Do any additional setup after loading the view from its nib.
    [self setupMenuBarButtonItems];
    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    self.customerNameLabel.textColor = col2;
    self.customerNameLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    self.startTimeLabel.textColor = col2;
    self.customerNameLabel.text = self.currentJob.clientName;
    self.customerCompanyLabel.text = self.currentJob.clientCompany;
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@", self.currentJob.jobStartTime];
    NSArray *timeArray = [self.currentJob.jobEndTime componentsSeparatedByString:@":"];
    self.hour = [[timeArray objectAtIndex:0] intValue];
    self.mins = [[timeArray objectAtIndex:1] intValue];
    [self updateTimeLabel];
}
-(void) updateTimeLabel
{
    //end time
    int minstemp = self.mins;
    int hourtemp = self.hour;
    if (minstemp == 0)
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:0%d", hourtemp, minstemp ];
    else
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:%d", hourtemp, minstemp ];
    self.currentJob.jobEndTime = self.endTimeLabel.text;
    self.tempJobEndTime = self.endTimeLabel.text;
    
    //start time
    int minstemp2 = self.minsStart;
    int hourtemp2 = self.hourStart;
    if (minstemp2 == 0)
        self.startTimeLabel.text = [NSString stringWithFormat:@"%d:0%d", hourtemp2, minstemp2 ];
    else
        self.startTimeLabel.text = [NSString stringWithFormat:@"%d:%d", hourtemp2, minstemp2 ];
    self.currentJob.jobStartTime = self.startTimeLabel.text;
    self.tempJobStartTime = self.startTimeLabel.text;

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)removeStartTime:(id)sender
{
    if ([self.currentJob.jobStartTimeOriginal integerValue] > 120)
    {
    self.isRed = NO;
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    Job* tempJob = [[Job alloc]init];
    int tempIndex = 0;
    int x = 0;
    for (Job* thisJob in self.jobList)
    {
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
            tempJob = thisJob;
            tempIndex = x;
        }
        x++;
    }
    int timeAdding = [tempJob.jobDuration intValue];
    timeAdding -= 30;
    NSDate * theDate =tempJob.jobDate ;
    ((Job*)[self.jobList objectAtIndex:tempIndex]).jobDate = [theDate dateByAddingTimeInterval:3600*.5];
    self.currentJob.jobDate = [theDate dateByAddingTimeInterval:-3600*.5];
    self.tempJobDate = [theDate dateByAddingTimeInterval:-3600*.5];
    self.currentJob.jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    self.currentJob.jobStartTimeOriginal = [NSNumber numberWithInt:[self.currentJob.jobStartTimeOriginal integerValue] - 30 ];
    self.tempJobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    ((Job*)[self.jobList objectAtIndex:tempIndex]).jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    [self updateTimeLabel];
    if (self.minsStart == 0)
    {
        self.minsStart = 30;
        self.hourStart--;
        if (self.hourStart == 0)
            self.hourStart = 12;
    }
    else
    {
        self.minsStart = 0;
    }
    //update the ending time label
    if (self.mins == 0)
    {
        self.mins = 30;
        self.hour--;
        if (self.hour == 0)
            self.hour = 12;
    }
    else
    {
        self.mins = 0;
    }

    if ([self.jobList count] > 0)
    {
        Job* thisJob = [self.jobList objectAtIndex:0];
        NSNumber* i = thisJob.jobStartTimeOriginal;
        int  j = [i integerValue]%60;
        
        [MSTimeRowHeader coordinate:[i integerValue]/60 andMinutes:j];
        [MJTimeIndicator coordinate:[i integerValue]/60 andMinutes:j];

    }
    [self updateTimeLabel];
    
    [self sortArray];
    [self viewDidLoad];
    }
    
}

- (IBAction)addStartTime:(id)sender
{
    if (([self.currentJob.jobStartTimeOriginal integerValue] + [self.currentJob.jobDuration integerValue]) < 1440)
    {
    self.isRed = NO;
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    Job* tempJob = [[Job alloc]init];
    int tempIndex = 0;
    int x = 0;
    for (Job* thisJob in self.jobList)
    {
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
            tempJob = thisJob;
            tempIndex = x;
        }
        x++;
    }
    int timeAdding = [tempJob.jobDuration intValue];
    timeAdding -= 30;
    NSDate * theDate =tempJob.jobDate ;
    ((Job*)[self.jobList objectAtIndex:tempIndex]).jobDate = [theDate dateByAddingTimeInterval:3600*.5];
    self.tempJobDate = [theDate dateByAddingTimeInterval:3600*.5];
    self.tempJobStartTimeOriginal =[NSNumber numberWithInt:[self.currentJob.jobStartTimeOriginal integerValue] + 30 ];
    self.currentJob.jobDate = [theDate dateByAddingTimeInterval:3600*.5];
    self.currentJob.jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    self.currentJob.jobStartTimeOriginal = [NSNumber numberWithInt:[self.currentJob.jobStartTimeOriginal integerValue] + 30 ];
    self.tempJobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    ((Job*)[self.jobList objectAtIndex:tempIndex]).jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
    [self updateTimeLabel];
    //update the start time label
    if (self.minsStart == 0)
        self.minsStart = 30;
    else
    {
        self.minsStart = 0;
        self.hourStart++;
        if (self.hourStart== 13)
            self.hourStart = 1;
    }
    //update the ending time label
    if (self.mins == 0)
    {
        self.mins = 30;
    }
    else
    {
        self.mins = 0;
        self.hour++;
        if (self.hour == 13)
            self.hour = 1;
    }
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobDate" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray * sortedArray = [self.jobList sortedArrayUsingDescriptors:descriptors];
    self.jobList = sortedArray;
    [self sortArray];
    if ([self.jobList count] > 0)
    {
        Job* thisJob = [sortedArray objectAtIndex:0];
        NSNumber* i = thisJob.jobStartTimeOriginal;
        int  j = [i integerValue]%60;
        [MSTimeRowHeader coordinate:[i integerValue]/60 andMinutes:j];
        [MJTimeIndicator coordinate:[i integerValue]/60 andMinutes:j];
    }
    [self updateTimeLabel];
    [self sortArray];
    [self viewDidLoad];
    }
}

- (IBAction)addTime:(id)sender
{
    int spaceNumber = 0;
    Job* tempJob = [[Job alloc]init];
    int tempIndex = 0;
    int x = 0;
    for (Job* thisJob in self.jobList)
    {
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
            tempJob = thisJob;
            tempIndex = x;
        }
        x++;
    }
    //determine if there is space left
    if ([self.jobList count] > self.indexJob + 1)
    {
        Job* job = [self.jobList objectAtIndex:tempIndex];
        Job* job2 = [self.jobList objectAtIndex:tempIndex + 1];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        NSNumber * myNumber = [f numberFromString:job2.jobDuration];
        NSNumber * myNumber2 = [f numberFromString:job.jobDuration];
        spaceNumber = [myNumber integerValue] - [myNumber2 integerValue];
        NSDate * firstDate = job.jobDate;
        NSDate * secondDate = job2.jobDate;
        NSTimeInterval diff = [secondDate timeIntervalSinceDate:firstDate];    //dateToApiString:(NSDate *)date
        NSInteger time = diff;
        spaceNumber = time;
        spaceNumber = spaceNumber /60;
        spaceNumber= spaceNumber-[myNumber2 integerValue];
    }
    else spaceNumber = 10;
    if (spaceNumber > 0)
    {
        int timeAdding = [((Job*)[self.jobList objectAtIndex:tempIndex]).jobDuration intValue];
        timeAdding += 30;
        ((Job*)[self.jobList objectAtIndex:tempIndex]).jobDuration = [NSString stringWithFormat:@"%d", timeAdding];
         self.currentJob.jobDuration = [NSString stringWithFormat:@"%d", timeAdding];
        self.tempJobDuration = [NSString stringWithFormat:@"%d", timeAdding];
        if (self.mins == 0)
            self.mins = 30;
        else
        {
            self.mins = 0;
            self.hour++;
            if (self.hour == 13)
                self.hour = 1;
        }
        [self updateTimeLabel];
        [self sortArray];
        [self viewDidLoad];
    }
}
- (IBAction)removeTime:(id)sender
{
    self.isRed = NO;
    Job* tempJob = [[Job alloc]init];
    int tempIndex = 0;
    int x = 0;
    for (Job* thisJob in self.jobList)
    {
        
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
            tempJob = thisJob;
            tempIndex = x;
        }
        x++;
    }
    int time = [((Job*)[self.jobList objectAtIndex:tempIndex]).jobDuration intValue];
    if (time > 30)
    {
        time -= 30;
        ((Job*)[self.jobList objectAtIndex:tempIndex]).jobDuration = [NSString stringWithFormat:@"%d", time];
        self.currentJob.jobDuration = [NSString stringWithFormat:@"%d", time];
        self.tempJobDuration = [NSString stringWithFormat:@"%d", time];

        [self sortArray];
        [self viewDidLoad];
        if (self.mins == 0)
        {
            self.mins = 30;
            self.hour--;
            if (self.hour == 0)
                self.hour = 12;
        }
        else
        {
            self.mins = 0;
        }
        [self updateTimeLabel];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        [self loadRoutes];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)loadRoutes
{
    CopyMoveRouteViewController *vc = [[CopyMoveRouteViewController alloc] init];
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JunkSideMenuCell";
    UserDefaultsSingleton *defaults =[UserDefaultsSingleton sharedInstance];
    JunkSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"JunkSideMenuCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (indexPath.row == 0)
    {
        cell.nameLabel.text = [NSString stringWithFormat:@"To Route: %@", [defaults getUserDefaultRouteName]];
    }
    if (indexPath.row == 1)
    {
        cell.nameLabel.text =  [NSString stringWithFormat:@"%@", self.currentJob.jobStartTime];
    }
    if (indexPath.row == 2)
    {
        cell.nameLabel.text =  [NSString stringWithFormat:@"%@", self.currentJob.jobEndTime];
    }
    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    cell.nameLabel.textColor = col2;
    cell.nameLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
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
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
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
        int edgeInset = 15;
        if (spaceNumber < 0)
        {
            self.isRed = YES;
            edgeInset = 80;
            self.navigationItem.rightBarButtonItem = nil;
        }
        spaceNumber = spaceNumber * 2;
        spaceNumber = spaceNumber * 1.33333;
        return UIEdgeInsetsMake(0, edgeInset, spaceNumber+1, 0);
    }
    return UIEdgeInsetsMake(0, 15, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 1;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return [self.jobList count];
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MJJobCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MJJobCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.job = [self.jobList objectAtIndex:indexPath.section];
    if (self.currentJob.jobID == cell.job.jobID)
    {
        cell.isSelected = TRUE;
        cell.isRed = self.isRed;
    }
    else
    {
        cell.isSelected = FALSE;
        cell.isRed = self.isRed;
    }
    return cell;
}

# pragma mark - Job list Methods

- (void)getJobListForCurrentRoute
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.currentDate = [DateHelper now];
    [DataStoreSingleton sharedInstance].currentDate = self.currentDate;
    if ([DataStoreSingleton sharedInstance].currentRoute)
    {
        [[FetchHelper sharedInstance] fetchJobListForRoute:[DataStoreSingleton sharedInstance].currentRoute.routeID andDate:self.currentDate withAlert:NO];
    }
    else
    {
        NSNumber *defaultRouteID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
        [[FetchHelper sharedInstance] fetchJobListForRoute:defaultRouteID andDate:self.currentDate withAlert:NO];
    }
}

- (void)getJobListForCurrentRouteYesterday
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _currentDate = [DateHelper yesterday:_currentDate];
    [DataStoreSingleton sharedInstance].currentDate = _currentDate;
    if ([DataStoreSingleton sharedInstance].currentRoute)
    {
        [[FetchHelper sharedInstance] fetchJobListForRoute:[DataStoreSingleton sharedInstance].currentRoute.routeID andDate:_currentDate withAlert:NO];
    }
    else
    {
        NSNumber *defaultRouteID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
        [[FetchHelper sharedInstance] fetchJobListForRoute:defaultRouteID andDate: _currentDate withAlert:NO];
    }
}
- (IBAction)nextWasPressed:(id)sender
{
    [self getJobListForCurrentRouteTomorrow];
    if (self.currentDate)
    {
        self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
    }
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSQuarterCalendarUnit fromDate:self.currentJob.jobDate];
    [dc setDay:dc.day + 1];
    self.currentJob.jobDate  = [[NSCalendar currentCalendar] dateFromComponents:dc];
    self.tempJobDate = self.currentJob.jobDate;
    self.prevButton.enabled = NO;
    self.nextButton.enabled = NO;
}


- (IBAction)previousWasPressed:(id)sender
{
    [self getJobListForCurrentRouteYesterday];
    if (self.currentDate)
    {
        self.dateLabel.text = [DateHelper dateToJobListString:self.currentDate];
    }
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSQuarterCalendarUnit fromDate:self.currentJob.jobDate];
    [dc setDay:dc.day - 1];
     self.currentJob.jobDate  = [[NSCalendar currentCalendar] dateFromComponents:dc];
    self.tempJobDate = self.currentJob.jobDate;

    self.prevButton.enabled = NO;
    self.nextButton.enabled = NO;
}
- (void)getJobListForCurrentRouteTomorrow
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _currentDate = [DateHelper tomorrow:_currentDate];
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



#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
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

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
}


- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveJob)];
}

- (void)refreshJobListAndShowAlert
{
    [self hideProgressEnableSave];

    [self.refreshControl endRefreshing];
    [self sortArray];
    
    self.prevButton.enabled = YES;
    self.nextButton.enabled = YES;
}

-(void)logTimes
{
    NSLog(@"-------------");
    for (Job* thisJob in self.jobList)
    {
        NSLog(@"%@\n", thisJob.jobDate);
    }
    NSLog(@"-------------");

}

-(void)saveJob
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    if ([self.uiSwitch isOn])
    {
        [self moveJob:NO];
    }
    else
    if (self.originalDuration > [self.currentJob.jobDuration integerValue])
    {
        [self saveDuration:YES];
    }
    else
    {
        [self moveJob:YES];
    }

}

-(void)saveDuration:(BOOL)needsAMove
{
    Job* job = self.currentJob;
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:job.jobDuration];
    
    needsMove = needsAMove;
    
    [[FetchHelper sharedInstance] updateJob:self.currentJob.jobID withDuration:myNumber];
}

- (void)updateJobSuccessful
{
    [Flurry logEvent:@"Adjust Duration"];

    if (needsMove)
    {
        [self moveJob:NO];
    }
    else
    {
        [self hideProgressEnableSave];

        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)updateJobFailed
{
    [self hideProgressEnableSave];
}

- (void)hideProgressEnableSave
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)moveJob:(BOOL)needsADuration
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSInteger routeID = 0;
    
    if ([[DataStoreSingleton sharedInstance] currentRoute])
    {
        routeID = [[[DataStoreSingleton sharedInstance] currentRoute].routeID integerValue];
    }
    else
    {
        routeID = [[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] integerValue];
    }
    
    NSString *jobType = @"";
    if (self.uiSwitch.isOn)
    {
        jobType = @"Copy";
        [Flurry logEvent:@"Copy Job"];
    }
    else
    {
        jobType = @"Move";
        [Flurry logEvent:@"Move Job"];
    }

    needsDuration = needsADuration;
    
    [[FetchHelper sharedInstance] copyMoveJob:self.currentJob.jobID jobType:jobType routeID:routeID jobStartTimeOriginal:self.currentJob.jobStartTimeOriginal];
}

- (void)copyMoveJobSuccessful
{
    if (needsDuration)
    {
        [self saveDuration:NO];
    }
    else
    {
        [self hideProgressEnableSave];

        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)copyMoveJobFailed
{
    if (needsDuration)
    {
        [self saveDuration:NO];
    }
    
    [self hideProgressEnableSave];
}

-(BOOL)isFound
{
    for (Job *j in self.jobList)
    {
        if ([j.jobID integerValue] == [self.currentJob.jobID integerValue])
            return YES;
    }
    return NO;
}
-(void)insertCJob
{
    Job* tempJob = [[Job alloc]init];
    BOOL didNotFind = YES;
    int tempIndex = 0;
    int x = 0;
    for (Job* thisJob in self.jobList)
    {
        
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
            tempJob = thisJob;
            tempIndex = x;
            didNotFind = NO;
        }
        x++;
    }
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:self.jobList];

    if (didNotFind)
    {
        [tempArray addObject:self.currentJob];
        self.jobList = [NSArray arrayWithArray:tempArray];
    }
  
  
    
}
-(void)adjustCurrentJob
{
    for (Job* thisJob in self.jobList)
    {
        
        if ([thisJob.jobID integerValue] == [self.currentJob.jobID integerValue])
        {
           
            thisJob.jobStartTimeOriginal = self.currentJob.jobStartTimeOriginal;
            thisJob.jobStartTime = self.currentJob.jobStartTime;
            if (self.tempJobStartTimeOriginal)
                thisJob.jobStartTimeOriginal = self.tempJobStartTimeOriginal;
            if (self.tempJobDate)
                thisJob.jobDate = self.tempJobDate;
            if (self.tempJobStartTime)
                thisJob.jobStartTime = self.tempJobStartTime;
            if (self.tempJobEndTime)
                thisJob.jobEndTime = self.tempJobEndTime;
            if (self.tempJobDuration)
                thisJob.jobDuration = self.tempJobDuration;
        }
    }
}
-(void)sortArray
{
        
    self.jobList = [DataStoreSingleton sharedInstance].jobList;
    [self adjustCurrentJob];

    [self insertCJob];
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobDate" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray * sortedArray = [self.jobList sortedArrayUsingDescriptors:descriptors];
    self.jobList = sortedArray;
    Job *newJob = [[Job alloc] init];
    newJob.jobDuration = @"0";
    newJob.jobStartTime = @"300";
    newJob.jobStartTimeOriginal = [(Job*)[self.jobList objectAtIndex:0] jobStartTimeOriginal];
    newJob.jobStartTimeOriginal = [NSNumber numberWithInt:[newJob.jobStartTimeOriginal integerValue] - 120 ];
    NSDate *theDate =  [(Job*)[self.jobList objectAtIndex:0] jobDate];
    newJob.jobDate = [theDate dateByAddingTimeInterval:-3600*2];
    Job *newJob1 = [[Job alloc] init];
    newJob1.jobDuration = @"0";
    newJob1.jobStartTime = @"300";
    newJob1.jobStartTimeOriginal = [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobStartTimeOriginal];
    int intDuration = [[NSString stringWithFormat:@"%@",  [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobDuration]] intValue];
    int intDuration2 = [[(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobDuration] integerValue];
    newJob1.jobStartTimeOriginal = [NSNumber numberWithInt:[newJob1.jobStartTimeOriginal integerValue] + 60 + intDuration];
    NSDate *theDate1 = [(Job*)[self.jobList objectAtIndex:[self.jobList count]-1] jobDate];
    newJob1.jobDate = [theDate1 dateByAddingTimeInterval:60*intDuration2 + 3600];
    NSMutableArray * tempArray = [NSMutableArray arrayWithArray:self.jobList];
    [tempArray addObject:newJob1];
    [tempArray addObject:newJob];
    if ([self.uiSwitch isOn])
    {
        if (self.copiedJob)
            [tempArray addObject:self.copiedJob];
    }
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

    [self.collectionView reloadData];
    [self logTimes];
}

- (void)refreshJobList
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self sortArray];
    [self.collectionView reloadData];

    self.prevButton.enabled = YES;
    self.nextButton.enabled = YES;
}

@end
