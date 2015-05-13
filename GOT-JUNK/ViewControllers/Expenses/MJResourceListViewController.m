//
//  MJResourceListViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-11.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "Resource.h"
#import "FetchHelper.h"
#import "DataStoreSingleton.h"
#import "JNExpenseDetailViewController.h"
#import "MJResourceListViewController.h"
#import "Flurry.h"
@interface MJResourceListViewController ()

@end

@implementation MJResourceListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResourcesList) name:@"FetchResourcesListComplete" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Resource List"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[DataStoreSingleton sharedInstance].resourcesList removeAllObjects];
    
    self.resourcesList = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSArray * resourcesList = [self getFilteredResourcesList];
    if (resourcesList)
    {
        
        self.resourcesList = resourcesList;
        [self.resourcesTableView reloadData];
    }
    else
    {
        [self fetchResourcesList];
    }
}

// called after doing a fetch of resources from the API
- (void)refreshResourcesList
{
    // the resources list will be filtered already, so need to call getFilteredResourcesList()
    self.resourcesList = [[DataStoreSingleton sharedInstance] resourcesList];
}

- (void)fetchResourcesList
{
    [[FetchHelper sharedInstance] fetchResources:self.itemID];
}

- (NSArray *)getFilteredResourcesList
{
    NSArray * resourcesList = [[DataStoreSingleton sharedInstance] resourcesList];
    if (!resourcesList || resourcesList.count == 0) return nil;
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"resourceTypeID = %d", self.itemID];
    return [resourcesList filteredArrayUsingPredicate:predicate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resourcesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Resource * resource = [self getResourceForRow:indexPath.row];
    
    cell.textLabel.text = resource.resourceName;
    
    return cell;
}

- (Resource *)getResourceForRow:(int)rowID
{
    Resource * data = (Resource *)([self.resourcesList objectAtIndex:rowID]);
    return data;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // get chosen resource
    Resource * resource = [self getResourceForRow:indexPath.row];
    
    NSArray * viewControllers = [self.navigationController viewControllers];
    
    // get reference to the enviro details screen
    UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 2)];
    
    if (!vc) {
        return;
    }
    ((JNExpenseDetailViewController *)vc).myResource = resource;
    
    // Pop the view controller.
    [self.navigationController popViewControllerAnimated:YES];
    
    self.didChooseItem = YES;
}
 


@end
