//
//  MJExpenseAccountsTableViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-25.
//  Copyright (c) 2013 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJExpenseAccountsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray * expenseAccountsList;
@property (nonatomic, strong) IBOutlet UITableView *expenseAccountsListTableView;
//@property int expenseTypeID;
@end
