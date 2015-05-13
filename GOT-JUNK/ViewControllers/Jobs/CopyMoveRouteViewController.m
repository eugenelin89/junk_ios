//
//  CopyMoveRouteViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-11-22.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "CopyMoveRouteViewController.h"
#import "DataStoreSingleton.h"
#import "Route.h"
#import "FetchHelper.h"
#import "UserDefaultsSingleton.h"
@interface CopyMoveRouteViewController ()

@end

@implementation CopyMoveRouteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Route *route = [self.routeList objectAtIndex:indexPath.row];
    [DataStoreSingleton sharedInstance].currentRoute= route;
    [DataStoreSingleton sharedInstance].jobList = nil;
    [DataStoreSingleton sharedInstance].enviroDict = nil;
    
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
    
    // load up the jobs for this chosen route, but block until complete
    [[FetchHelper sharedInstance] fetchJobListForRoute:route.routeID andDate:currentDate withAlert:NO];
    
    UserDefaultsSingleton *defaults =[UserDefaultsSingleton sharedInstance];
    
    [defaults setUserDefaultRouteID:route.routeID];
    [defaults setUserDefaultRouteName:route.routeName];
        [self.navigationController popViewControllerAnimated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
