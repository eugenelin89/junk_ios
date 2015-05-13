//
//  FranchiseListViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 5/13/13.
//  Copyright (c) 2013 1800-Got-Junk. All rights reserved.
//

#import "JunkViewController.h"

@interface FranchiseListViewController : JunkViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *franchiseList;
@property (nonatomic, strong) IBOutlet UITableView *franchiseListTableView;


@end
