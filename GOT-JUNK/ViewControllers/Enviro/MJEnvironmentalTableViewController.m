//
//  MJEnvironmentalTAbleViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-28.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "UIColor+ColorWithHex.h"
#import "MJEnvironmentalCell.h"
#import "MJEnvironmentalTableViewController.h"
#import "MJEnvironmentalDetailViewController.h"
#import "DataStoreSingleton.h"
#import "Job.h"
#import "Enviro.h"
#import "Route.h"
#import "MFSideMenuContainerViewController.h"
#import "FetchHelper.h"
#import "UserDefaultsSingleton.h"
#import "MBProgressHUD.h"
#import "UnitConversionHelper.h"

@interface MJEnvironmentalTableViewController ()

@end

@implementation MJEnvironmentalTableViewController

BOOL isJobListLoaded = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEnviroList) name:@"FetchEnviroListComplete" object:nil];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.enviroDict = [DataStoreSingleton sharedInstance].enviroDict;
    
    [self setupMenuBarButtonItems];
    [self setupNotificationObservers];
    
   
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setupNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEnviroSuccessful) name:@"SendDeleteEnvironmentalSuccessful" object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteEnviroFailed) name:@"SendDeleteEnvironmentalFailure" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchLoadTypeSizeSuccessful) name:@"FetchLoadTypeSizeListComplete" object:nil];
    
}

- (void)fetchLoadTypeSizeSuccessful
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)deleteEnviroSuccessful
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Hoorah!"
                       message:@"The environmental record was successfully deleted."
                       delegate:self
                       cancelButtonTitle:@"Close"
                       otherButtonTitles: nil];
    [av show];
    
    [self.tableView reloadData];
}

- (void)deleteEnviroFailure
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Gadzooks!"
                       message:@"The environmental record could not be deleted.  Please try again."
                       delegate:self
                       cancelButtonTitle:@"Close"
                       otherButtonTitles: nil];
    [av show];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[DataStoreSingleton sharedInstance].enviroDict = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    
    [super viewDidAppear:animated];
    
    NSDictionary *enviroDict = [[DataStoreSingleton sharedInstance] enviroDict];
    
    // get just the list of jobs
    NSArray * jobsAndBookoffsList = [[DataStoreSingleton sharedInstance] jobList];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"jobType != 3"];
    self.jobList = [jobsAndBookoffsList filteredArrayUsingPredicate:predicate];
    
    // load up the list of the enviro entries
    if ((!enviroDict) || (enviroDict.count == 0)){
        
        [self getData];
        
    } else {
        self.enviroDict = [DataStoreSingleton sharedInstance].enviroDict;
        [self.tableView reloadData];
        
    }
    
    // start loading up the load type sizes
    NSArray * loadTypeSizes = [DataStoreSingleton sharedInstance].loadTypeSizeList;
    
    if (!loadTypeSizes || loadTypeSizes.count == 0){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[FetchHelper sharedInstance] fetchLoadTypeSizes];
    }
}



- (void)getData
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"You are in offline Mode and you have no cached enviromental data" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
    else
    {
    int routeID = [[[DataStoreSingleton sharedInstance] currentRoute].routeID integerValue];
    if (!routeID || routeID==0){
        routeID = [[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] integerValue];
    }
    NSDate * date = [DataStoreSingleton sharedInstance].currentDate;
    [[FetchHelper sharedInstance] fetchEnviroByRoute:routeID onDate:date];
    }
}

// gets run when the enviro list is loaded up through the webservice
- (void)refreshEnviroList
{
    self.enviroDict = [DataStoreSingleton sharedInstance].enviroDict;
    [self.tableView reloadData];
    
    //[MBProgressHUD hideHUDForView:self.view animated:YES];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.

    // Return the number of sections.
    return self.jobList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // get the jobID
    int jobID = [self getJobIDBySectionIndex:section];
    NSNumber * j = [[NSNumber alloc] initWithInt:jobID];
    
    // return the # of enviro records associated with this job
    return ((NSArray *)([self.enviroDict objectForKey:j])).count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MJEnvironmentalCell";
    
    MJEnvironmentalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MJEnvironmentalCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    // get the jobID for this particular section
    NSNumber * jobID = [[NSNumber alloc] initWithInt:[self getJobIDBySectionIndex:indexPath.section]];

    // get the enviro record to display at the current position
    Enviro * enviro = (Enviro *)([(NSArray *)([[DataStoreSingleton sharedInstance].enviroDict objectForKey:jobID]) objectAtIndex:indexPath.row]);
    
    // populate the labels
    NSString * numberOfTrucks = @"";
    if (enviro.numberOfTrucks > 0)
        numberOfTrucks = [NSString stringWithFormat:@"%d ", enviro.numberOfTrucks];
    
    cell.junkType.text = enviro.junkType;
    
    NSString * truckLoads = [[NSString alloc] init];
    
    // 1 1/4 bedload
    if (enviro.numberOfTrucks > 0){
        truckLoads = [truckLoads stringByAppendingFormat:@"%d ", enviro.numberOfTrucks];
    }
    
    if (![enviro.loadTypeSize isEqualToString:@"0"])
        truckLoads = [truckLoads stringByAppendingFormat:@"%@ ", enviro.loadTypeSize];
    
    truckLoads = [truckLoads stringByAppendingFormat:@"%@", enviro.loadType];
    
    cell.truckLoads.text = truckLoads;
    
    // Diverted: 30% (300 short tons)
    cell.diversion.text = [NSString stringWithFormat:@"Diverted: %.2f%% (%.2f %@)", [self getEnviroDiversion:enviro], [UnitConversionHelper convertWeight:[self getEnviroWeight:enviro] fromType:1 toType:enviro.weightTypeID], enviro.weightType];
    cell.destination.text = [NSString stringWithFormat:@"at %@", enviro.destination];
    
    return cell;
}

- (float)getEnviroWeight:(Enviro *)enviro
{
    if (enviro.actualWeight >= 0){
        return enviro.actualWeight;
    } else {
        return enviro.calculatedWeight;
    }
}

- (float)getEnviroDiversion:(Enviro *)enviro
{
    if (enviro.userDiversion >= 0){
        return enviro.userDiversion;
    } else {
        return enviro.defaultDiversion;
    }
}

- (int)getJobIDBySectionIndex:(int)sectionIndex
{
    
    // get the jobID
    return [((Job *)[self.jobList objectAtIndex:sectionIndex]).jobID integerValue];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}


- (UIView*) tableView: (UITableView*) tableView
viewForHeaderInSection: (NSInteger) section
{
    
    Job* thisJob = [self.jobList objectAtIndex:section];
    
    // need to filter out the bookoffs!
    
    
    UIView* customView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 60.0)];
    
    // red - enviro is required but not entered
    // blue - enviro has been entered
    // green - enviro not required and has not been entered
    
    
    //customView.backgroundColor = [UIColor colorWithRed:127.0/255.0 green: 186.0/255.0 blue: 0.0 alpha: 0.7];
    
    NSMutableDictionary * enviroDict = [[DataStoreSingleton sharedInstance] enviroDict];
    
    BOOL hasEnviroData = YES;
    // check if this job has any enviro records
    if (((NSArray *)[enviroDict objectForKey:thisJob.jobID]).count == 0)
    {
        hasEnviroData = NO;
    }
    
    if (hasEnviroData)
    {
        // blue
        customView.backgroundColor = [UIColor colorWithRed:15/255.0f green:162/255.0f blue:248/255.0f alpha:1.0f];
    }
    else if (thisJob.isEnviroRequired)
    {
        // red
        customView.backgroundColor = [UIColor colorWithRed:255/255.0f green:17/255.0f blue:25/255.0f alpha:1.0f];
    }
    else {
        // green
        customView.backgroundColor = [UIColor colorWithRed:127.0/255.0 green: 186.0/255.0 blue: 0.0 alpha: 0.7];
    }
    
    
    
  
    
    /* make button one pixel less high than customView above, to account for separator line */
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake(5.0, 10.0, 35.0, 35.0)];
    
    button.tag = [((Job *)([self.jobList objectAtIndex:section])).jobID integerValue];
    
    button.alpha = 0.7;
    [button setImage: [UIImage imageNamed:@"plus-icon.png" ] forState: UIControlStateNormal];
    
    /* Prepare target-action */
    [button addTarget: self action: @selector(headerTapped:)
     forControlEvents: UIControlEventTouchUpInside];
    
    // jobID
    UILabel * jobIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(250,25, 100, 15)];
    jobIDLabel.backgroundColor = [UIColor clearColor];
    jobIDLabel.textAlignment = NSTextAlignmentLeft;
    jobIDLabel.textColor = [UIColor blackColor];
    jobIDLabel.text = [NSString stringWithFormat:@"%d", [thisJob.jobID intValue]];
    jobIDLabel.font = [UIFont fontWithName:@"Arial" size:13];
    
    // promise time
    UILabel * promiseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45,25, 200, 15)];
    promiseTimeLabel.backgroundColor = [UIColor clearColor];
    promiseTimeLabel.textAlignment = NSTextAlignmentLeft;
    promiseTimeLabel.textColor = [UIColor blackColor];
    promiseTimeLabel.text = [NSString stringWithFormat:@"%@", thisJob.promiseTime];
    promiseTimeLabel.font = [UIFont fontWithName:@"Arial" size:13];
    
    
    // zip code, client name
    UILabel  * jobInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 300, 20)];
    jobInfoLabel.backgroundColor = [UIColor clearColor];
    jobInfoLabel.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter, UITextAlignmentLeft
    jobInfoLabel.textColor=[UIColor blackColor];
    jobInfoLabel.text = [NSString stringWithFormat:@"%@ %@", thisJob.zipCode, thisJob.clientName];
    
    [customView addSubview:jobIDLabel];
    [customView addSubview:jobInfoLabel];
    [customView addSubview:button];
    [customView addSubview:promiseTimeLabel];
    UIButton *button1 = [[UIButton alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 60.0)];
    button1.tag = [((Job *)([self.jobList objectAtIndex:section])).jobID integerValue];
    button1.backgroundColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
    button1.alpha = 1.0;
    
    
    [button1 setImage: [UIImage imageNamed:@"plus-icfon.png" ] forState: UIControlStateNormal];
    
    /* Prepare target-action */
    [button1 addTarget: self action: @selector(headerTapped:) forControlEvents: UIControlEventTouchUpInside];
    [customView addSubview: button1];

    return customView;
}

- (void) headerTapped: (UIButton*) sender
{
    
    if ([DataStoreSingleton sharedInstance].isConnected)
    {
        MJEnvironmentalDetailViewController *vc = [[MJEnvironmentalDetailViewController alloc] init];
        
        // get the job that we just clicked on
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobID = %d", sender.tag];
        NSArray * results = [self.jobList filteredArrayUsingPredicate:predicate];
        Job * job = [[Job alloc] init];
        if (results && results.count > 0)
            job = [results objectAtIndex:0];
        vc.job = job;
        self.editing = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"You are in offline Mode.  You cannot create new expenses in offline mode" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJEnvironmentalDetailViewController * detailViewController = [[MJEnvironmentalDetailViewController alloc] init];
    
    
    // get the job
    
    Job * job = [self.jobList objectAtIndex:indexPath.section];

    Enviro * enviro = (Enviro *)([((NSArray *)([[DataStoreSingleton sharedInstance].enviroDict objectForKey:job.jobID]))objectAtIndex:indexPath.row]);
    
    detailViewController.job = job;
    detailViewController.enviro = enviro;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSNumber * jobID = ((Job *)([self.jobList objectAtIndex:indexPath.section])).jobID;
        
        NSMutableArray * enviroList = [[DataStoreSingleton sharedInstance].enviroDict objectForKey:jobID];
        
        // delete the chosen enviro breakdown
        
        [enviroList removeObjectAtIndex:indexPath.row];
        [[FetchHelper sharedInstance] saveEnviro:enviroList isDeletion:YES forJobID:[jobID intValue]];
        
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UIBarButtonItems

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

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return nil;
    
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

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

@end
