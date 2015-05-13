//
//  MJJunkTypesListViewController.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJunkTypesListViewController.h"
#import "DataStoreSingleton.h"
#import "FetchHelper.h"
#import "MJEnvironmentalDetailViewController.h"

@interface MJJunkTypesListViewController ()

@end

@implementation MJJunkTypesListViewController

bool didChooseJunkType = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshJunkTypesList) name:@"FetchJunkTypesListComplete" object:nil];
        
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
    
    if ([DataStoreSingleton sharedInstance].junkTypesList && [[DataStoreSingleton sharedInstance].junkTypesList count] > 0)
    {
        self.junkTypesList = [DataStoreSingleton sharedInstance].junkTypesList;
        [self.junkTypesTableView reloadData];
    }
    else
    {
        [self getEnviroJunkTypesList];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!didChooseJunkType){
        [DataStoreSingleton sharedInstance].currentLookupMode = @"";
    } else {
        [DataStoreSingleton sharedInstance].currentLookupMode = @"ENVIRONMENTJUNKTYPE";
    }
}

- (void)getEnviroJunkTypesList
{
    
    [[FetchHelper sharedInstance] fetchJunkTypes];
    //[[FetchHelper sharedInstance] fetchLookup:@"ENVIRONMENTJUNKTYPE" itemID:nil languageID:nil userID:nil];
}

- (void)refreshJunkTypesList
{
    self.junkTypesList = [[DataStoreSingleton sharedInstance] junkTypesList];
    [self.junkTypesTableView reloadData];
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
    return [self.junkTypesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    JunkType *lookup = [self.junkTypesList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = lookup.itemName;
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    didChooseJunkType = YES;
    
    JunkType * junkType = (JunkType *)([self.junkTypesList objectAtIndex:indexPath.row]);
    NSArray * viewControllers = [self.navigationController viewControllers];
    
    // get reference to the enviro details screen
    UIViewController *vc = [viewControllers objectAtIndex:(viewControllers.count - 2)];
    
    if (!vc) {
        return;
    }
    ((MJEnvironmentalDetailViewController *)vc).junkType = junkType;
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
