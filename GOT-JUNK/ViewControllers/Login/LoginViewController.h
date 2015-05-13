//
//  LoginViewController.h
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//
#import "LoginViewController.h"
#import "AFHTTPRequestOperation.h"
#import "JSONParserHelper.h"
#import "UserDefaultsSingleton.h"
#import "Franchise.h"
#import "DataStoreSingleton.h"
#import "Flurry.h"
#import "Route.h"
#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate,UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) IBOutlet UITableView *loginTableView;
@property (nonatomic, strong) UITextField *usernameTF;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UILabel *onlineStatus;
@property (nonatomic, strong) IBOutlet UILabel *junknetStatus;
@property (nonatomic, strong) UIAlertView *av;
@property (nonatomic, strong)  NSString *applicationURL;
@property (nonatomic, strong)  NSString *currentVersion;
- (IBAction)loginWasPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *debug1;
@property (weak, nonatomic) IBOutlet UILabel *debug2;

@end
