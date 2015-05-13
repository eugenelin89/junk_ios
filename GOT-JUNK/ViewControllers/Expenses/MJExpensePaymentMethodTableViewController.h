//
//  MJExpensePaymentMethodTableViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-26.
//  Copyright (c) 2013 Gargoyle Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJExpensePaymentMethodTableViewController : UIViewController

@property (nonatomic, strong) NSArray * expensePaymentMethodsList;
@property (nonatomic, strong) IBOutlet UITableView * expensePaymentMethodsListTableView;


@end
