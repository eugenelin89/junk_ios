//
//  JunkSideMenuViewController.h
//  MFSideMenuDemoBasic
//
//  Created by Mark Pettersson on 2013-07-05.
//  Copyright (c) 2013 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Job.h"

@interface MenuInfo : NSObject

@property (nonatomic) Class screenClass;
@property (nonatomic) NSString *screenTitle;
@property (nonatomic) NSString *menuTitle;
@property (nonatomic) NSString *menuImageName;

- (instancetype)initMenu:(Class)viewClass withTitle:(NSString*)title withMenuTitle:(NSString*)menuTitle withMenuImageName:(NSString*)imageName;

@end

@interface JunkSideMenuViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView * tableView;

@end
