//
//  MJEnvironmentalTAbleViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-28.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJEnvironmentalTableViewController : UITableViewController 
@property (nonatomic, strong) NSMutableDictionary *enviroDict;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) NSArray *jobList;
@property int routeID;
@property int dayID;
@end
