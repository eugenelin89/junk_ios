//
//  MJExpensesTableViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-28.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJExpensesTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary * expensesDict;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@end
