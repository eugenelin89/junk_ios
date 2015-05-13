//
//  MJNotificationsTableViewController.h
//  GOT-JUNK
//
//  Created by David Block on 2015-04-08.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJNotificationsTableViewController : UITableViewController
- (IBAction)refresh:(UIRefreshControl *)sender;
@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshUpControl;

@end
