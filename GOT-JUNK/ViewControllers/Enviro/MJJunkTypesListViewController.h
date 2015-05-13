//
//  MJJunkTypesListViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LookupTableViewController.h"

@interface MJJunkTypesListViewController : LookupTableViewController

@property (nonatomic, strong) NSArray * junkTypesList;
@property (nonatomic, strong) IBOutlet UITableView * junkTypesTableView;

@end
