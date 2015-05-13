//
//  JobPhoneListViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

@interface JobPhoneListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) Job * currentJob;

@end
