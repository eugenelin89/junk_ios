//
//  RouteListViewController.h
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "JunkViewController.h"

@interface RouteListViewController : JunkViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *routeList;
@property (nonatomic, strong) IBOutlet UITableView *routeListTableView;

- (void)setRequiresBack:(BOOL)requiresBack;

@end
