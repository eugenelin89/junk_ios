//
//  MJAdjustJobViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJAdjustJobViewController.h"
#import "MFSideMenuContainerViewController.H"
#import "DataStoreSingleton.h"
#import "Job.h"
#import "MJJobCell.h"
#import "UIColor+ColorWithHex.h"
#import "FetchHelper.h"
#import "MJCopyMoveViewController.h"
#import "MBProgressHUD.h"
#import "MSGridline.h"
#import "MSTimeRowHeader.h"

@interface MJAdjustJobViewController ()
@property(nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation MJAdjustJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobSuccessful) name:@"UpdateJobSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateJobFailed) name:@"UpdateJobFailed" object:nil];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    MJCollectionViewCalendarLayout *automationLayout = (MJCollectionViewCalendarLayout *)self.collectionView.collectionViewLayout;
    [automationLayout registerClass:[MSGridline class]  forDecorationViewOfKind:@"MSGridLine"];
    [automationLayout registerClass:[MSTimeRowHeader class]  forDecorationViewOfKind:@"MSTimeRowHeader"];
    [self.collectionView reloadData];

 
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadCurrentJob];
    [self.collectionView reloadData];
}
-(void)loadCurrentJob
{
    self.title = [NSString stringWithFormat:@"%@", self.currentJob.jobID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MJJobCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:@"MJJobCell"];
    self.jobList = [DataStoreSingleton sharedInstance].jobList;
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jobDate" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray * sortedArray = [self.jobList sortedArrayUsingDescriptors:descriptors];
    self.jobList = sortedArray;
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

- (IBAction)saveJobDuration:(id)sender
{
    Job* job = self.currentJob;
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber * myNumber = [f numberFromString:job.jobDuration];
    
    [[FetchHelper sharedInstance] updateJob:self.currentJob.jobID withDuration:myNumber];
}

- (IBAction)moveCopy:(id)sender
{
    MJCopyMoveViewController *myViewController = [[MJCopyMoveViewController alloc] initWithNibName:@"MJCopyMoveViewController" bundle:nil];
    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
//    myViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:navigationController animated:YES completion:nil];
    myViewController.currentJob = self.currentJob;
    myViewController.indexJob = self.indexJob;
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:0.7];
    [self.navigationController pushViewController: myViewController animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];


}
-(void) updateTimeLabel
{
    int minstemp = self.mins;
    int hourtemp = self.hour;
    if (minstemp == 0)
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:0%d", hourtemp, minstemp ];
    else
        self.endTimeLabel.text = [NSString stringWithFormat:@"%d:%d", hourtemp, minstemp ];
    self.currentJob.jobEndTime = self.endTimeLabel.text;


}
-(void)startRefresh
{
  //  [self.refreshControl endRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        spaceNumber = abs(spaceNumber);
        spaceNumber = spaceNumber * 2;
        spaceNumber = spaceNumber * 1.33333;
        return UIEdgeInsetsMake(0, 25, spaceNumber+1, 0);
    }
    return UIEdgeInsetsMake(0, 25, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    Job *selectedJob = [self.jobList objectAtIndex:indexPath.section];
//    
//    if ([selectedJob isBookoff]) {
//        // reject the click
//    } else {
//        self.currentJob = selectedJob;
//        self.indexJob = indexPath.section;
//        [self loadCurrentJob];
//        [self.collectionView reloadData];
//    }
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
//    NSInteger myInt = indexPath.section;
    if (cell.job.jobID == self.currentJob.jobID)
        cell.isSelected = TRUE;
    else
        cell.isSelected = FALSE;
    return cell;
}


- (IBAction)addTime:(id)sender
{
  
    int spaceNumber = 0;
    //determine if there is space left
    if ([self.jobList count] > self.indexJob + 1)
    {
    Job* job = [self.jobList objectAtIndex:self.indexJob];
    Job* job2 = [self.jobList objectAtIndex:self.indexJob+1];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    //  [f setNumberStyle:NSN];
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
        int timeAdding = [((Job*)[self.jobList objectAtIndex:self.indexJob]).jobDuration intValue];
        timeAdding += 30;
        ((Job*)[self.jobList objectAtIndex:self.indexJob]).jobDuration = [NSString stringWithFormat:@"%d", timeAdding];
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
        [self.collectionView reloadData];
        [self viewDidLoad];
    }
}
- (IBAction)removeTime:(id)sender
{
 
    int time = [((Job*)[self.jobList objectAtIndex:self.indexJob]).jobDuration intValue];
    if (time > 30)
    {
        time -= 30;
        ((Job*)[self.jobList objectAtIndex:self.indexJob]).jobDuration = [NSString stringWithFormat:@"%d", time];
        [self.collectionView reloadData];
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
    return [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveJobDuration:)];
}

- (void)updateJobSuccessful
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)updateJobFailed
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


@end
