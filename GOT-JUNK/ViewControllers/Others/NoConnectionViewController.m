//
//  NoConnectionViewController.m
//  GOT-JUNK
//
//  Created by David Block on 2014-11-18.
//  Copyright (c) 2014 David Block. All rights reserved.
//

#import "NoConnectionViewController.h"
#import "FetchHelper.h"

@interface NoConnectionViewController ()

@end

@implementation NoConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnected) name:RECONNECTED_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)reconnected
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retryPressed:(id)sender
{
    [[FetchHelper sharedInstance] fetchJobListForDefaultRouteAndCurrentDate];
}

- (IBAction)logoutPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutRequest" object:nil];

    }];
    

}

@end
