//
//  OfflineLoginViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2014-09-16.
//  Copyright (c) 2014 1800 Got Junk. All rights reserved.
//

#import "OfflineLoginViewController.h"
#import "DateHelper.h"
#import "NSString+MD5.h"
#import "FetchHelper.h"

@interface OfflineLoginViewController ()
@property int countAttempts;
@end

@implementation OfflineLoginViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnected) name:RECONNECTED_NOTIFICATION object:nil];

    self.countAttempts = 0;
    self.loginTableView.backgroundColor = [UIColor clearColor];
    UIImage *buttonImage = [[UIImage imageNamed:@"button-green.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"button-green-press.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(15, 6, 15, 6)];
    [self.loginButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    self.usernameTF.text = @"";
    self.passwordTF.text = @"";
    
}

- (void)reconnected
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // In case there is a lingering password
    [[FetchHelper sharedInstance] clearUsernamePassword];
    
    [[FetchHelper sharedInstance] getSystemInfo];
    
    self.usernameTF.text = @"";
    self.passwordTF.text = @"";
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
        [self login];
    }
    return NO;
}

# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
        tv.placeholder = @"Offline Access Key";
        
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
    self.usernameTF.text = @"";
    self.passwordTF.text = @"";
    return cell;
}

# pragma mark - Login/Logout

- (IBAction)loginWasPressed:(id)sender
{
    // remove keyboard from screen
    [self.usernameTF resignFirstResponder];
    [self.usernameTF resignFirstResponder];
    
    // login
    [self login];
}

- (void)login
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

#ifdef DEVELOPMENT_MODE
    NSString *username = @"Gargoyle";
    NSString *password = @"8Ktf4UMF";
#else
    NSString *username = self.usernameTF.text;
#endif
    
    //special algorithm for offline mode as details in secretoffline access key google document
    NSString *myString =  [DateHelper nowString];  //todays date
    int myDateNumber2 = [myString integerValue];  //converted into a number
    int myDateNumber = [myString integerValue]; //converted into a number
    myDateNumber = myDateNumber % 7 + 2;  //mode 7 + 2
    int myDateNumberFact = [self factorialX: myDateNumber];  //factorial
    int myFinal = myDateNumberFact + myDateNumber2;  //add together
    NSString * myHashString = [NSString stringWithFormat:@"%d", myFinal];  //convert into a string
    NSString * myHashStringHashed = [myHashString MD5String];  //hash it with MD5String
    myHashStringHashed =  [myHashStringHashed substringToIndex:10];  //trim to 10 characters
    
   if ([[username uppercaseString] isEqualToString:myHashStringHashed])
   {
       [[UserDefaultsSingleton sharedInstance] storeOfflineKey:username];
       [[UserDefaultsSingleton sharedInstance] offlineModeEnabled];
       [DataStoreSingleton sharedInstance].isUserLoggedIn = YES;
       [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
   }
    else
    {
        self.countAttempts ++;
        int remaining = 3 - self.countAttempts;
        if (self.countAttempts < 3)
        {
           UIAlertView *failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"You have %d attempts", remaining] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [failedLoginAlert show];

        }
        else
        {
             UIAlertView *failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"You can no longer access offline Mode" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [failedLoginAlert show];
            [[UserDefaultsSingleton sharedInstance] clearAllData];
            [[DataStoreSingleton sharedInstance] deleteAllData];

        }
        [[UserDefaultsSingleton sharedInstance] offlineModeDisabled];
    }
}

-(double) factorialX: (int) value
{
    double tempResult = 1;
    for (int i=2; i<=value; i++) {
        tempResult *= i;
    }
    return tempResult;
}

@end
