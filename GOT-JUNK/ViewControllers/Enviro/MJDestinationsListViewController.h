//
//  MJDestinationsListViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LookupTableViewController.h"

@interface MJDestinationsListViewController : LookupTableViewController 

@property (strong, nonatomic) NSArray * destinationsList;
@property (strong, nonatomic) IBOutlet UITableView * destinationsTableView;

@end
