//
//  MJDestinationsListViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJDestinationsListViewController.h"
#import "DataStoreSingleton.h"
#import "FetchHelper.h"
#import "EnviroDestination.h"
#import "MJEnvironmentalDetailViewController.h"

@interface MJDestinationsListViewController ()

@end

@implementation MJDestinationsListViewController

bool didChooseDestination = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDestinationList) name:@"FetchDestinationListComplete" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    //[super viewDidAppear:animated];
    
    if ([DataStoreSingleton sharedInstance].enviroDestinationsList && [[DataStoreSingleton sharedInstance].enviroDestinationsList count] > 0)
    {
        self.destinationsList = [DataStoreSingleton sharedInstance].enviroDestinationsList;
        [self.destinationsTableView reloadData];
    }
    else
    {
        [self getEnviroDestinationsList];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!didChooseDestination){
        [DataStoreSingleton sharedInstance].currentLookupMode = @"";
    } else {
        [DataStoreSingleton sharedInstance].currentLookupMode = @"ENVIRONMENTALDESTINATIONS";
    }
}

- (void)getEnviroDestinationsList
{
    
    [[FetchHelper sharedInstance] fetchEnviroDestinations];
    //[[FetchHelper sharedInstance] fetchLookup:@"ENVIRONMENTJUNKTYPE" itemID:nil languageID:nil userID:nil];
}

- (void)refreshDestinationList
{
    self.destinationsList = [[DataStoreSingleton sharedInstance] enviroDestinationsList];
    [self.destinationsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.destinationsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    EnviroDestination *lookup = [self.destinationsList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = lookup.itemName;
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    didChooseDestination = YES;
    
    EnviroDestination * destination = (EnviroDestination *)([self.destinationsList objectAtIndex:indexPath.row]);
    NSArray * viewControllers = [self.navigationController viewControllers];
    
    // get reference to the enviro details screen
    UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 2)];
    
    if (!vc) {
        return;
    }
    ((MJEnvironmentalDetailViewController *)vc).enviroDestination = destination;
    [self.navigationController popViewControllerAnimated:YES];

}



@end
