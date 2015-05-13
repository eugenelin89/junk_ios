//
//  MJResourceListViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-11.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LookupTableViewController.h"

@interface MJResourceListViewController : LookupTableViewController

//@property int resourceTypeID;
@property (nonatomic, strong) NSArray * resourcesList;
@property (nonatomic, strong) IBOutlet UITableView * resourcesTableView;

@end
