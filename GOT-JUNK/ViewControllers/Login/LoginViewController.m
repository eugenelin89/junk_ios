//
//  LoginViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "LoginViewController.h"
#import "UserDefaultsSingleton.h"
#import "DateHelper.h"
#import "FetchHelper.h"
#import "Route.h"
#import "Mode.h"
#import "OfflineLoginViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) UIActionSheet *upgradeActionSheet;
@end

@implementation LoginViewController

@synthesize loginTableView = _loginTableView;
@synthesize usernameTF = _usernameTF;
@synthesize passwordTF = _passwordTF;
@synthesize loginButton = _loginButton;
@synthesize upgradeActionSheet = _upgradeActionSheet;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"LoginViewController view did load");
    
    // Mode Transition Notifications
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:LOGGEDOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGGEDIN_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:DISCONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus) name:RECONNECTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentUpgradeMenu) name:@"UpdateAvailable" object:nil];
    

    
    
    [Flurry logEvent:@"Login Controller"];
    self.loginTableView.backgroundColor = [UIColor clearColor];
    UIImage *buttonImage = [[UIImage imageNamed:@"button-green.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"button-green-press.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(15, 6, 15, 6)];
    [self.loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateStatus];
    
    // In case there is a lingering password
    [[FetchHelper sharedInstance] clearUsernamePassword];
    [[FetchHelper sharedInstance] getSystemInfo];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self newVersionCheck];
    
//    self.debug1.text = [DataStoreSingleton sharedInstance].debugDisplayText1;
//    self.debug2.text = [DataStoreSingleton sharedInstance].debugDisplayText2;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.upgradeActionSheet dismissWithClickedButtonIndex:0 animated:NO];
    [super viewWillAppear:animated];
}


- (void)updateStatus
{
    if( [DataStoreSingleton sharedInstance].isConnected == YES )
    {
        self.onlineStatus.text = @"Connected to JunkNet";
        self.onlineStatus.textColor = [UIColor blueColor];
    }
    else
    {
        self.onlineStatus.text = @"Not connected to JunkNet";
        self.onlineStatus.textColor = [UIColor redColor];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Data Rendering

- (NSString *)storedUsername
{
    UserDefaultsSingleton *defaults = [UserDefaultsSingleton sharedInstance];
    NSString *username = [defaults getUserLogin];
    
    return username;
}

# pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTF)
    {
        [self.usernameTF resignFirstResponder];
        [self.passwordTF becomeFirstResponder];
    }
    else
    {
        [self.passwordTF resignFirstResponder];
        [self loginWasPressed:nil];
    }
    return NO;
}

# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITextField *tv = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LoginTableViewCell" owner:self options:nil];
        cell = (UITableViewCell*)[objects objectAtIndex:0];
    }
    
    if (!tv) { tv = (UITextField*)[cell viewWithTag:1];}
    
    if (indexPath.row == 0)
    {
        tv.placeholder = @"Username";
        
        tv.delegate = self;
        
        self.usernameTF = tv;
        
        NSString *username = [self storedUsername];
        if (username) {
            tv.text = username;
        } else {
            [self.usernameTF becomeFirstResponder];
        }
    }
    else
    {
        tv.placeholder = @"Password";
        tv.secureTextEntry = YES;
        tv.delegate = self;
        tv.returnKeyType = UIReturnKeyDone;
        self.passwordTF = tv;
        
        if ([self storedUsername])
        {
            [tv becomeFirstResponder];
        }
        else
        {
            // No big deal. the other one will be first responder
        }
    }
    
    return cell;
}

# pragma mark - Login/Logout

- (void)loginSuccess
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.loginButton setEnabled:YES];

    //Dismissal of LoginViewControler should be handled by its presenting view controller.
}

- (void)loginFailed
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    UIAlertView *failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [failedLoginAlert show];
    
    [self.loginButton setEnabled:YES];
}

#pragma mark - Deal With Response

# pragma mark - Button IBActions
- (IBAction)loginWasPressed:(id)sender
{
    [self.loginButton setEnabled:NO];
    
    [self.usernameTF resignFirstResponder];
    
    NSString *username = self.usernameTF.text;
    NSString *password = self.passwordTF.text;
    
    [[FetchHelper sharedInstance] login:username withPassword:password];
}

# pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( actionSheet.tag == 1 )
    {
        if (buttonIndex == 0)
        {
            NSString* launchUrl = [[DataStoreSingleton sharedInstance].appUpgradeInfo objectForKey:@"applicationURL"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
        }
        return;
    }
}

-(void)newVersionCheck
{
    [[FetchHelper sharedInstance] checkAppUpgrade];
}

-(void)presentUpgradeMenu
{
   
    self.upgradeActionSheet = [[UIActionSheet alloc]
                                  initWithTitle:[NSString stringWithFormat:@"A newer version of JunkNet Mobile is available.  Would you like to upgrade?"]
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  destructiveButtonTitle:@"Yes!"
                                  otherButtonTitles:nil];
    self.upgradeActionSheet.tag = 1;
    [self.upgradeActionSheet showInView:self.view];
}


@end
