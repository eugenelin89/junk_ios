//
//  LookupTableViewController.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LookupTableViewController : UITableViewController

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * mode;
@property int itemID;
@property int languageID;
@property int userID;
@property BOOL didChooseItem;

@property (nonatomic, strong) NSArray * lookupList;
@property (nonatomic, strong) IBOutlet UITableView * lookupListTableView;

@end
