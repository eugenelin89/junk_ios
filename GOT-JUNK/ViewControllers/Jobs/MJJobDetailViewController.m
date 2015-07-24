//
//  MJJobDetailViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobDetailViewController.h"
#import "MJJobDetailViewCell.h"
#import "UIColor+ColorWithHex.h"
#import "JobPhoneListViewController.h"
#import "MJJobCancelViewController.h"
#import "MJJobPaymentViewController.h"
#import "EditContactViewController.h"
#import "DataStoreSingleton.h"
#import "MJNASADetailsViewController.h"
#import "MBProgressHUD.h"
#import "NotesViewController.h"
#import "MJNPSViewController.h"
#import "MJEnvironmentalTableViewController.h"
#import "FetchHelper.h"
#import "MJCopyMoveViewController.h"
#import "DateHelper.h"
#import "MJJobPaymentAusViewController.h"
#import "UserDefaultsSingleton.h"

@interface MJJobDetailViewController ()

@end

@implementation MJJobDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithJob:(Job*)job
{
    self = [super initWithNibName: @"MJJobDetailViewController" bundle: nil];
    if (self) {
        self.currentJob = job;

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobConverted) name:@"ConvertCompleteSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jobNotConverted) name:@"ConvertCompleteFailure" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptDispatchCompleteSuccessful) name:@"AcceptDispatchCompleteSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptDispatchCompleteFailure) name:@"AcceptDispatchCompleteFailure" object:nil];

    
    self.title  = @"";
    self.calling = NO;
   NSString* tempPermissions =  [DataStoreSingleton sharedInstance].permissions;
    if ( [tempPermissions isEqualToString:@"Truck Team Member"])
    {
       self.moveAdjustButton.hidden = YES;
       self.cancelButton.hidden = YES;
    }
    else
    {
       self.moveAdjustButton.hidden = NO;
       self.cancelButton.hidden = NO;
    }
    if (self.currentJob.isEnviroRequired == YES)
    {
        self.enviroButton.hidden = NO;
        self.enviroLabel.hidden = NO;
    }
    else
    {
        self.enviroButton.hidden = YES;
        self.enviroLabel.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.calling)
    {
        self.calling = NO;
        [self callStatusButtonAction:nil];
    }
    [super viewWillAppear:animated];
    
    [self.scrollView setContentOffset:CGPointZero];

    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    self.customerNameLabel.textColor = col2;
    self.customerNameLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    self.customerCompanyLabel.textColor = col2;
    self.customerCompanyLabel.font =  [UIFont fontWithName:@"Arial Black" size:18];
    self.customerCompanyLabel.text = self.currentJob.clientCompany;
    self.title = [NSString stringWithFormat:@"%@",self.currentJob.jobID];
    self.timeLabel.textColor = col2;
    self.customerNameLabel.text = self.currentJob.clientName;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@\n%@", self.currentJob.jobStartTime, self.currentJob.jobEndTime, self.currentJob.promiseTime];
    self.notesField.text = self.currentJob.comments;
     if ([self.currentJob.callAheadStatus isEqualToString: @"Incomplete"])
     {
    UIImage *btnImage = [UIImage imageNamed:@"notphoned_white.png"];
    [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
     }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
        [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
    }
    float tempTotal = [self.currentJob.total floatValue]/100;
    
    if ([self.currentJob.total integerValue]> 0)
        [self.paymentStatusButton setTitle:[NSString stringWithFormat:@"$%0.02f", tempTotal] forState:UIControlStateNormal];
    else if ([self.currentJob.jobType integerValue] != 2)
        [self.paymentStatusButton setTitle:@"Payments" forState:UIControlStateNormal];
    else
        [self.paymentStatusButton setTitle:@"Convert Estimate" forState:UIControlStateNormal];


    [self.callStatusButton setTitle:self.currentJob.callAheadStatus forState:UIControlStateNormal];
    switch ([self.currentJob.clientTypeID integerValue]) {
           case 1:
            {
                if ([self.currentJob.total integerValue]> 0)
                {
                UIImage *image = [UIImage imageNamed: @"houseGreenChecked.png"];
                    self.jobImageType.image=image;
                }
                else
                {
                    UIImage *image = [UIImage imageNamed: @"houseGreen.png"];
                    self.jobImageType.image=image;
                }
            }
            break;
            case 2:
            {
                if ([self.currentJob.junkCharge integerValue]> 0)
                {
                    UIImage *image = [UIImage imageNamed: @"commercialGreenChecked.png"];
                    self.jobImageType.image=image;
                }
                else
                {
                    UIImage *image = [UIImage imageNamed: @"commercialGreen.png"];
                    self.jobImageType.image=image;
                }
            }
                break;
            default:
                break;
       }
    if ([self.currentJob.jobType integerValue] == 2)
    {
        UIImage *image = [UIImage imageNamed: @"pencilGreen.png"];
        self.jobImageType.image = image;// [[UIImageView alloc] initWithImage: image];
    }
    
    [self refreshJob];
}

- (void)refreshJob
{
    if( [self.currentJob isDispatchJob] == YES )
    {
        NSString *imageName;
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 1, 320, 46);
        
        if( [self.currentJob isDispatchJobAccepted] == YES )
        {
            imageName = @"bg_popover_success.png";
            
            [btn setTitle:@"Job Accepted" forState:UIControlStateNormal];
            [btn setUserInteractionEnabled:NO];
        }
        else
        {
            imageName = @"bg_popover_error.png";
            
            [btn setTitle:@"Accept Job" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(acceptDispatchForJob) forControlEvents:UIControlEventTouchDown];
        }
        
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [backImage setFrame:CGRectMake(0, 1, 325, 49)];
        [self.dispatchView addSubview:backImage];
        
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.tag = 19;
        [self.dispatchView addSubview:btn];
        [self.dispatchView setHidden:NO];

        self.scrollViewHeightCon.constant = 47.f;
    }
    else
    {
        self.scrollViewHeightCon.constant = 0.f;
        
        [self.dispatchView setHidden:YES];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadEmail
{
    if (self.currentJob.clientEmail && ![self.currentJob.clientEmail isEqualToString:@""] && [MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
            
        [controller setToRecipients:[NSArray arrayWithObject:self.currentJob.clientEmail]];
        [controller setSubject:@""];
        [controller setMessageBody:@"" isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)callStatusButtonAction:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Set Call Ahead Status"
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Incomplete",@"Ignored",@"Not Needed",@"No answer",@"Left Message",@"Complete",@"N/A",@"Cancel", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /// Cancel pressed
    if( buttonIndex == 7 )
    {
        return;
    }
    
    [self setCallStatus:buttonIndex];
    switch (buttonIndex)
    {
        case 0:
        {
            self.currentJob.callAheadStatus = @"Incomplete";
            UIImage *btnImage = [UIImage imageNamed:@"notphoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 1:
        {
            self.currentJob.callAheadStatus = @"Ignored";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 2:
        {
            self.currentJob.callAheadStatus = @"Not Needed";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 3:
        {
            self.currentJob.callAheadStatus = @"No Answer";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 4:
        {
            self.currentJob.callAheadStatus = @"Left Message";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 5:
        {
            self.currentJob.callAheadStatus = @"Complete";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        case 6:
        {
            self.currentJob.callAheadStatus = @"N/A";
            UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
            [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
    [self.callStatusButton setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
}

- (IBAction)setCallStatus:(NSInteger)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
        NSString *senderString = [NSString stringWithFormat:@"%ld", (long)sender +1 ];
        [[FetchHelper sharedInstance] setCallStatus:self.currentJob.jobID statusID:senderString];
    }
}

# pragma mark - UITableViewDataSource Methods

-(void)calculateDistance
{
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JunkSideMenuCell";
    
    MJJobDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MJJobDetailViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    int row = indexPath.row;

    if (row == 0)
    {
        cell.titleLabel.text = [DateHelper dateToJobListString:self.currentJob.jobDate];
        cell.dataLabel.text = [NSString stringWithFormat:@"Scheduled Time: %@ - %@\nPromised %@", self.currentJob.jobStartTime, self.currentJob.jobEndTime, self.currentJob.promiseTime];
    }
    else if (row == 1)
    {
        if ([self.currentJob.contactPhonePref isEqualToString:@"Home"])
        {
            cell.titleLabel.text = @"main";
            if ((self.currentJob.contactHomePhone != (id)[NSNull null] || self.currentJob.contactHomePhone.length != 0 ))
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactHomeAreaCode, self.currentJob.contactHomePhone]];
                if ([mu length] > 4)
                {
                    [mu insertString:@"-" atIndex:9];
                }
                cell.dataLabel.text = mu;
            }
        }
        if ([self.currentJob.contactPhonePref isEqualToString:@"Cell"])
        {
            cell.titleLabel.text = @"cell";
            if ((self.currentJob.contactCell != (id)[NSNull null] || self.currentJob.contactCell.length != 0 ))
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactCellAreaCode, self.currentJob.contactCell]];
                if ([mu length] > 4)
                    [mu insertString:@"-" atIndex:9];
                
                cell.dataLabel.text = mu;
            }
        }
        if ([self.currentJob.contactPhonePref isEqualToString:@"Work"])
        {
            cell.titleLabel.text = @"work";
            if ((self.currentJob.contactWorkPhone != (id)[NSNull null] || self.currentJob.contactWorkPhone.length != 0 ))
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactWorkAreaCode, self.currentJob.contactWorkPhone]];
                if ([mu length] > 4)
                    [mu insertString:@"-" atIndex:9];
                cell.dataLabel.text = mu;
            }
        }
        if ([self.currentJob.onSiteContactPhone length] > 0)
        {
            cell.titleLabel.text = @"onsite";
            NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.onSiteContactAreaCode, self.currentJob.onSiteContactPhone]];
            if ([mu length] > 4)
                [mu insertString:@"-" atIndex:9];
                cell.dataLabel.text = mu;
        }
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        btn.frame = CGRectMake(280, 20, 24, 24);
        btn.tag = 1111;
        [btn addTarget:self
                   action:@selector(viewPhoneNumbers:)
         forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:btn];
    }
    else if (row == 2)
    {
        cell.titleLabel.text = @"pick up";
        if ([self.currentJob.pickupCompany length] > 3)
            cell.dataLabel.text = [NSString stringWithFormat:@"%@ at %@, %@", self.currentJob.pickupCompany, self.currentJob.pickupAddress, self.currentJob.zipCode];
        else
            cell.dataLabel.text = [NSString stringWithFormat:@"%@, %@",self.currentJob.pickupAddress, self.currentJob.zipCode];
    }
    else if (row == 3)
    {
        cell.titleLabel.text = @"email";
        
        cell.dataLabel.text = self.currentJob.clientEmail;
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoDark];
        btn.frame = CGRectMake(280, 20, 24, 24);
        btn.tag = 2222;
        [btn addTarget:self
                action:@selector(editEmail:)
      forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:btn];
    }
    else if (row == 4)
    {
        cell.titleLabel.text = @"previous job info";
        NSString * thisNum = [NSString stringWithFormat:@"%@", self.currentJob.npsValue ];
        if ([thisNum integerValue] < 0)
            thisNum = @"N/A";
            
        if ([self.currentJob.totalSpent integerValue] > 1)
        {
            float tempNum = [self.currentJob.totalSpent floatValue]/100;
            cell.dataLabel.text = [NSString stringWithFormat:@"NPS: %@ Total Spend: $%0.02f\nLast TT:%@", thisNum, tempNum , self.currentJob.nameOfLastTTUsed];
        }
        else
            cell.dataLabel.text = @"New Customer";
    }
    else if (row == 5)
    {
        UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
        cell.dataLabel.textColor = col2;
        cell.dataLabel.font = [UIFont fontWithName:@"Arial Black" size:18];

        cell.titleLabel.text = @"special instructions";
        if (([self.currentJob.programNotes length] > 1) || ([self.currentJob.promoCode length] > 1))
        {
            cell.dataLabel.text = @"Special Instructions";
            cell.dataLabel.textColor = [UIColor redColor];
        }
        else
            cell.dataLabel.text = @"No Special Instructions";
    }
    else if (row == 6)
    {
        UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
        cell.dataLabel.textColor = col2;
        cell.dataLabel.font = [UIFont fontWithName:@"Arial Black" size:18];

        cell.titleLabel.text = @"price list";
        cell.dataLabel.text = self.currentJob.zoneName;
    }
    
    return cell;
}

- (void)acceptDispatchForJob
{
    //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to accept this dispatch job?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    //av.tag = 19;
    //[av show];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FetchHelper sharedInstance] acceptDispatchForJob:self.currentJob];
}

- (IBAction)viewPhoneNumbers:(id)sender
{
    JobPhoneListViewController *phoneViewController = [[JobPhoneListViewController alloc] init];
    phoneViewController.currentJob = self.currentJob;
    [self.navigationController pushViewController:phoneViewController animated:YES];
}

- (void) showOfflineIndicator
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"You are in offline Mode.  You cannot perform this action" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [av show];
}

- (IBAction)editEmail:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
    EditContactViewController *vc = [[EditContactViewController alloc] initWithJob:self.currentJob];
    [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)pressEnviro:(id)sender
{
    MJEnvironmentalTableViewController *detailViewController = [[MJEnvironmentalTableViewController alloc] init];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)pressPayment:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
    if (self.currentJob.isCentrallyBilled == YES)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"This is a centrally billed customer.  Do not charge on site." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
    else if (self.currentJob.isCashedOut == YES)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"This job has already been cashed out.  Cannot edit payments." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
    else if  ([self.currentJob.jobType integerValue] == 2)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to convert this estimate to a job?" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: @"Cancel", nil];
        [av setTag:10];
        av.delegate = self;
        [av show];
    }
    else
    {
        if ([self.currentJob.pickupCountry isEqualToString:@"Australia"])
        {
            MJJobPaymentAusViewController *paymentViewController = [[MJJobPaymentAusViewController alloc] init];
            paymentViewController.currentJob = self.currentJob;
            [self.navigationController pushViewController:paymentViewController animated:YES];
        }
        else
        {
            MJJobPaymentViewController *paymentViewController = [[MJJobPaymentViewController alloc] init];
            paymentViewController.currentJob = self.currentJob;
            [self.navigationController pushViewController:paymentViewController animated:YES];
        }
    }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView.tag == 10)
    {
        if ([title isEqualToString:@"Ok"])
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[FetchHelper sharedInstance] convertEstimate:self.currentJob] ;
        }
    }
    else if( alertView.tag == 19 && buttonIndex == 1 )
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[FetchHelper sharedInstance] acceptDispatchForJob:self.currentJob];
    }
}

-(void)jobConverted
{
    if ([self.currentJob.pickupCountry isEqualToString:@"Australia"])
    {
        MJJobPaymentAusViewController *paymentViewController = [[MJJobPaymentAusViewController alloc] init];
        paymentViewController.currentJob = self.currentJob;
        [self.navigationController pushViewController:paymentViewController animated:YES];
    }
    else
    {
        MJJobPaymentViewController *paymentViewController = [[MJJobPaymentViewController alloc] init];
        paymentViewController.currentJob = self.currentJob;
        [self.navigationController pushViewController:paymentViewController animated:YES];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)jobNotConverted
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Estimate was not successfully converted" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [av show];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (IBAction)cancelJob:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
    if ([self.currentJob.total intValue] > 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot cancel a job with revenue" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
    else
    {
        MJJobCancelViewController *cancelViewController = [[MJJobCancelViewController alloc] init];
        cancelViewController.currentJobID = self.currentJob.jobID;
        [self.navigationController pushViewController:cancelViewController animated:YES];
    }
    }
}

- (IBAction)pushNoteController:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
        NotesViewController *vc = [[NotesViewController alloc] initWithJob:self.currentJob];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)editJob:(id)sender
{
    if (![DataStoreSingleton sharedInstance].isConnected)
    {
        [self showOfflineIndicator];
    }
    else
    {
    if ([self.currentJob.total integerValue] > 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot move/adjust a job with revenue" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [av show];
    }
    else
    {
        MJCopyMoveViewController *calendarViewController = [[MJCopyMoveViewController alloc] init];
        calendarViewController.currentJob = self.currentJob;
        calendarViewController.indexJob = self.indexJob;
        [self.navigationController pushViewController:calendarViewController animated:YES];
    }
    }
}
# pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1)
        [self callPhoneNumber];
    if (indexPath.row == 2)
        [self launchMaps];
    if (indexPath.row == 3)
        [self loadEmail];
    if (indexPath.row == 4)
        [self loadNPS];
    if (indexPath.row == 5)
    {
        if (([self.currentJob.programNotes length] > 1) || ([self.currentJob.promoCode length] > 1))
        {
            [self loadNASA];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) loadNPS
{
    MJNPSViewController *calendarViewController = [[MJNPSViewController alloc] init];
    calendarViewController.currentJob = self.currentJob;
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

-(void) loadNASA
{
    MJNASADetailsViewController *calendarViewController = [[MJNASADetailsViewController alloc] init];
    calendarViewController.currentJob = self.currentJob;
    [self.navigationController pushViewController:calendarViewController animated:YES];
}

# pragma mark - EMail, Maps and Dialer
- (void)callPhoneNumber
{
    NSString *phoneNumber = nil;
    if ([self.currentJob.contactPhonePref isEqualToString:@"Home"])
    {
        phoneNumber = [self.currentJob.contactHomePhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNumber = [NSString stringWithFormat:@"%@%@",self.currentJob.contactHomeAreaCode, phoneNumber];
    }
    if ([self.currentJob.contactPhonePref isEqualToString:@"Cell"])
    {
        phoneNumber = [self.currentJob.contactCell stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNumber = [NSString stringWithFormat:@"%@%@",self.currentJob.contactCellAreaCode, phoneNumber];

    }
    if ([self.currentJob.contactPhonePref isEqualToString:@"Work"])
    {
        phoneNumber = [self.currentJob.contactWorkPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNumber = [NSString stringWithFormat:@"%@%@",self.currentJob.contactWorkAreaCode, phoneNumber];
    }
    if ([self.currentJob.onSiteContactPhone length] > 0)
    {
        phoneNumber = [self.currentJob.onSiteContactPhone stringByReplacingOccurrencesOfString:@"(" withString:@""];
        phoneNumber = [NSString stringWithFormat:@"%@%@",self.currentJob.onSiteContactAreaCode, phoneNumber];
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Phone Number: %@", phoneNumber);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNumber]]];
     self.currentJob.callAheadStatus = @"Complete";
    UIImage *btnImage = [UIImage imageNamed:@"phoned_white.png"];
    [self.callStatusButton setImage:btnImage forState:UIControlStateNormal];
    [self.callStatusButton setTitle:@"Complete" forState:UIControlStateNormal];

    [self setCallStatus:5];
}

- (void)launchMaps
{
    BOOL useGoogleMap = [[UserDefaultsSingleton sharedInstance] getUseGoogleMaps];
    if (useGoogleMap)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
        {
            NSString * addressString = self.currentJob.pickupAddress;
            addressString = [addressString stringByReplacingOccurrencesOfString:@"#" withString:@""];
            addressString = [addressString stringByReplacingOccurrencesOfString:@"\n" withString:@"+"];
            NSString *  tempstring = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@+%@&directionsmode=driving", [addressString stringByReplacingOccurrencesOfString:@" " withString:@"+"], self.currentJob.zipCode];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: tempstring]];
        }
    }
    else
    {
        NSString *maps = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%@+%@", [self.currentJob.pickupAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"],self.currentJob.zipCode];
        NSURL* url = [[NSURL alloc] initWithString:[maps stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)acceptDispatchCompleteSuccessful
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    self.currentJob = [DataStoreSingleton sharedInstance].currentJob;
    
    [self refreshJob];
}

- (void)acceptDispatchCompleteFailure
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"There was an error dispatching the job." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [av show];
}

@end
