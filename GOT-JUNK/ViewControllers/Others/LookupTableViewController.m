//
//  LookupTableViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LookupTableViewController.h"
#import "Lookup.h"
#import "DataStoreSingleton.h"
#import "FetchHelper.h"
@interface LookupTableViewController ()

@end

@implementation LookupTableViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLookupList) name:@"FetchLookupListComplete" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.didChooseItem = NO;
    self.Title = self.title;
    
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DataStoreSingleton sharedInstance].lookupList removeAllObjects];
    
    // check if any item got selected from the tableview; if not, then reset the lookup mode.

    if (!self.didChooseItem){
        [DataStoreSingleton sharedInstance].currentLookupMode = @"";
    } else {
        [DataStoreSingleton sharedInstance].currentLookupMode = self.mode;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.didChooseItem = NO;
    
    if ([DataStoreSingleton sharedInstance].lookupList && [[DataStoreSingleton sharedInstance].lookupList count] > 0)
    {
        self.lookupList = [DataStoreSingleton sharedInstance].lookupList;
        [self.lookupListTableView reloadData];
    }
    else
    {
        [self getLookupList];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLookupList
{
    [[FetchHelper sharedInstance] fetchLookup:self.mode
                                       itemID:self.itemID
                                   languageID:self.languageID
                                       userID:self.userID];
}
- (void)refreshLookupList
{
    self.lookupList = [DataStoreSingleton sharedInstance].lookupList;
    [self.lookupListTableView reloadData];

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
    return [self.lookupList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Lookup *lookup = [self.lookupList objectAtIndex:indexPath.row];
    cell.textLabel.text = lookup.itemName;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [[DataStoreSingleton sharedInstance] currentLookup].itemID = ((Lookup*) [self.lookupList objectAtIndex:indexPath.row]).itemID;
    [[DataStoreSingleton sharedInstance] currentLookup].itemName = ((Lookup*) [self.lookupList objectAtIndex:indexPath.row]).itemName;
    [self.navigationController popViewControllerAnimated:YES];
    self.didChooseItem = YES;
}

@end
