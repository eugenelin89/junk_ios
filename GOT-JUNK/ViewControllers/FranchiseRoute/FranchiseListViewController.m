//
//  FranchiseListViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "FranchiseListViewController.h"
#import "FetchHelper.h"
#import "DataStoreSingleton.h"
#import "Franchise.h"
#import "UserDefaultsSingleton.h"
#import "RouteListViewController.h"
#import "Flurry.h"
#import "MFSideMenuContainerViewController.h"

@interface FranchiseListViewController ()

@end

@implementation FranchiseListViewController

@synthesize franchiseList = _franchiseList;
@synthesize franchiseListTableView = _franchiseListTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFranchiseList) name:@"FetchFranchiseListComplete" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  self.view.backgroundColor = [UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1.0];
    [Flurry logEvent:@"Franchise List"];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if ([DataStoreSingleton sharedInstance].franchiseList && [[DataStoreSingleton sharedInstance].franchiseList count] > 0
      && ![DataStoreSingleton sharedInstance].isConnected )
  {
    self.franchiseList = [DataStoreSingleton sharedInstance].franchiseList;
    [self.franchiseListTableView reloadData];
  }
  else
  {
    [self getFranchiseList];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.franchiseList count];
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

    Franchise *franchise = [self.franchiseList objectAtIndex:indexPath.row];
    cell.textLabel.text = franchise.franchiseName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

# pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Franchise *franchise = [self.franchiseList objectAtIndex:indexPath.row];
    [DataStoreSingleton sharedInstance].currentFranchise = franchise;

    UserDefaultsSingleton *defaults =[UserDefaultsSingleton sharedInstance];
    [defaults setUserDefaultFranchiseID:franchise.franchiseID];
    [defaults setDefaultFranchiseName:franchise.franchiseName];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RouteListViewController *vc = [[RouteListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

# pragma mark - GET Franchise List

- (void)getFranchiseList
{
  [[FetchHelper sharedInstance] fetchFranchiseList];
}

- (void)refreshFranchiseList
{
  self.franchiseList = [DataStoreSingleton sharedInstance].franchiseList;
  [self.franchiseListTableView reloadData];
}

- (void)popViewController
{
  [self.navigationController popViewControllerAnimated:YES];
}


@end
