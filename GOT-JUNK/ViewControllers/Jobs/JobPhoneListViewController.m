//
//  JobPhoneListViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-09-26.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "JobPhoneListViewController.h"
#import "MJJobDetailViewCell.h"
#import "UIColor+ColorWithHex.h"
#import "PhoneEditCell.h"
#import "MBProgressHUD.h"
#import "FetchHelper.h"

@interface JobPhoneListViewController ()

@end

@implementation JobPhoneListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContatPhoneSuccessful) name:@"UpdateContatPhoneSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContatPhoneFailure) name:@"UpdateContatPhoneFailure" object:nil];
    }
    return self;
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scrollView setContentOffset:CGPointZero];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMenuBarButtonItems];
    self.title = @"Phone Numbers";

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
//-(UITableView *)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.tableView.editing == YES)
    {
        
        static NSString *CellIdentifier = @"PhoneEditCell";
        
        PhoneEditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PhoneEditCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLabel.text = @"Home";
             //   NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", self.currentJob.contactHomePhone]];
               // [mu insertString:@"-" atIndex:3];
                cell.phoneField.text = self.currentJob.contactHomePhone;
                cell.areaField.text = self.currentJob.contactHomeAreaCode;
                cell.extField.text = self.currentJob.contactHomeExt;
                cell.tag = 1234;
            }
                break;
            case 1:
                cell.titleLabel.text = @"Cell";
                cell.areaField.text = self.currentJob.contactCellAreaCode;
                cell.extField.text = self.currentJob.contactCellExt;
                cell.phoneField.text = self.currentJob.contactCell;
                
                break;
            case 2:
                cell.titleLabel.text = @"Work";
                cell.phoneField.text = self.currentJob.contactWorkPhone;
                cell.areaField.text = self.currentJob.contactWorkAreaCode;
                cell.extField.text = self.currentJob.contactWorkExt;
                
                break;
            case 3:
                cell.titleLabel.text = @"Pager";
                cell.phoneField.text = self.currentJob.contactPagerPhone;
                cell.areaField.text = self.currentJob.contactPagerAreaCode;
                cell.extField.text = self.currentJob.contactPagerExt;

                
                break;
            case 4:
                cell.titleLabel.text = @"Fax";
                cell.phoneField.text = self.currentJob.contactFax;
                cell.areaField.text = self.currentJob.contactFaxAreaCode;
                cell.extField.text = self.currentJob.contactFaxExt;
            case 5:
                cell.titleLabel.text = @"OnSite";
                cell.phoneField.text = self.currentJob.onSiteContactPhone;
                cell.areaField.text = self.currentJob.onSiteContactAreaCode;
                cell.extField.text = self.currentJob.onSiteContactExt;
                
                break;
            default:
                break;
        }
        
      //  UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
      //  cell.dataLabel.textColor = col2;
        //cell.dataLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
        return cell;
        
    }
    else
    {
    static NSString *CellIdentifier = @"MJJobDetailViewCell";
    
    MJJobDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MJJobDetailViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    switch (indexPath.row) {
        case 0:
        {
                cell.titleLabel.text = @"Home";
            NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.contactHomeAreaCode, self.currentJob.contactHomePhone, self.currentJob.contactHomeExt]];
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            if (mu.length > 8)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
            break;
        case 1:
        {
            cell.titleLabel.text = @"Cell";
     NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.contactCellAreaCode, self.currentJob.contactCell, self.currentJob.contactCellExt]];
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            
            if (mu.length > 8)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
            break;
        case 2:
        {
            cell.titleLabel.text = @"Work";
     NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.contactWorkAreaCode, self.currentJob.contactWorkPhone, self.currentJob.contactWorkExt]];
            
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            
            if (mu.length > 10)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
            break;
        case 3:
        {
            cell.titleLabel.text = @"Pager";
            NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.contactPagerAreaCode, self.currentJob.contactPagerPhone, self.currentJob.contactPagerExt]];
            NSString * nu = [mu stringByReplacingOccurrencesOfString:@"null" withString:@""];
            mu = [NSMutableString stringWithString:nu];
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            
            if (mu.length > 11)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
            break;
        case 4:
        {
            cell.titleLabel.text = @"Fax";
            NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.contactFaxAreaCode, self.currentJob.contactFax, self.currentJob.contactFaxExt]];
            NSString * nu = [mu stringByReplacingOccurrencesOfString:@"null" withString:@""];
            mu = [NSMutableString stringWithString:nu];
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            
            if (mu.length > 10)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
        case 5:
        {
            cell.titleLabel.text = @"Onsite";
            NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@ Ext:%@", self.currentJob.onSiteContactAreaCode, self.currentJob.onSiteContactPhone, self.currentJob.onSiteContactExt]];
            
            if ([mu length] > 9)
                [mu insertString:@"-" atIndex:9];
            
            if (mu.length > 10)
                cell.dataLabel.text = mu;
            else
                cell.dataLabel.text = @"";
        }
            break;
        default:
            break;
    }

    UIColor *col2 = [UIColor colorWithHexString:@"0x19338F" andAlpha:1.0];
    cell.dataLabel.textColor = col2;
    cell.dataLabel.font = [UIFont fontWithName:@"Arial Black" size:18];
    return cell;
    }
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, 0, 320, 100);
        self.scrollView.frame = CGRectMake(0, 0, 320, 100);
        self.tableView.frame = CGRectMake(0, 0, 320, 100);


    }];
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, 0, 320, 480);
        self.scrollView.frame = CGRectMake(0, 0, 320, 480);
        self.tableView.frame = CGRectMake(0, 0, 320, 480);

    }];
}

- (IBAction)savePhoneNumbers:(id)sender
{
    for (int i=0; i < 4; i++){ //nbPlayers is the number of rows in the UITableView
        
        PhoneEditCell *theCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
      
        switch (i) {
            case 0:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.contactHomeAreaCode = theCell.areaField.text;
                self.currentJob.contactHomeExt = theCell.extField.text;
                self.currentJob.contactHomePhone = nu;
                break;
            }
            case 1:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.contactCellAreaCode = theCell.areaField.text;
                self.currentJob.contactCellExt = theCell.extField.text;
                self.currentJob.contactCell = nu;
                break;
            }
            case 2:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.contactWorkAreaCode = theCell.areaField.text;
                self.currentJob.contactWorkExt = theCell.extField.text;
                self.currentJob.contactWorkPhone = nu;
                break;
            }
            case 3:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.contactPagerAreaCode = theCell.areaField.text;
                self.currentJob.contactPagerExt = theCell.extField.text;
                self.currentJob.contactPagerPhone = nu;
                break;
            }
            case 4:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.contactFaxAreaCode = theCell.areaField.text;
                self.currentJob.contactFaxExt = theCell.extField.text;
                self.currentJob.contactFax = nu;
                break;
            }
            case 5:
            {
                NSMutableString *mu = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", theCell.phoneField.text]];
                NSString * nu = [mu stringByReplacingOccurrencesOfString:@"-" withString:@""];
                self.currentJob.onSiteContactAreaCode = theCell.areaField.text;
                self.currentJob.onSiteContactExt = theCell.extField.text;
                self.currentJob.onSiteContactPhone = nu;
                
                break;
            }
                
            default:
                break;
        }
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            self.currentJob.contactHomeAreaCode, @"contactHomeAreaCode",
                            self.currentJob.contactHomePhone, @"contactHomePhone",
                            self.currentJob.contactHomeExt, @"contactHomeExt",
                            self.currentJob.contactWorkAreaCode, @"contactWorkAreaCode",
                            self.currentJob.contactWorkPhone, @"contactWorkPhone",
                            self.currentJob.contactWorkExt, @"contactWorkExt",
                            self.currentJob.contactCellAreaCode, @"contactCellAreaCode",
                            self.currentJob.contactCell, @"contactCellPhone",
                            self.currentJob.contactCellExt, @"contactCellExt",
                            self.currentJob.contactFaxAreaCode, @"contactFaxAreaCode",
                            self.currentJob.contactFax, @"contactFaxPhone",
                            self.currentJob.contactFaxExt, @"contactFaxExt",
                            self.currentJob.contactPagerAreaCode, @"contactPagerAreaCode",
                            self.currentJob.contactPagerPhone, @"contactPagerPhone",
                            self.currentJob.contactPagerExt, @"contactPagerExt",
                            self.currentJob.contactPhonePrefID, @"contactPhonePrefID",
                            self.currentJob.contactPhonePref, @"contactPhonePref",
                            self.currentJob.clientTypeID, @"clientTypeID",
                            self.currentJob.contactID, @"contactID",
                            @"1", @"onSiteContactID",
                            @"", @"onSiteContactAreaCode",
                            @"", @"onSiteContactPhone",
                            @"", @"onSiteContactExt",
                            @"1", @"onSiteContactPhonePrefID",
                            @"", @"onSiteContactPhonePref",
                            nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[FetchHelper sharedInstance] updateContactPhone:self.currentJob.jobID withParams:params];
}

- (void)updateContatPhoneSuccessful
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Phones Successful" message:@"The contact info has been stored in JunkNet" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [av show];
}

- (void)updateContatPhoneFailure
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Phone Numbers Failed" message:@"The contact info failed to save in JunkNet" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [av show];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"Empty Cell %d", indexPath.row];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * phoneNumber =[self.currentJob.contactHomePhone stringByReplacingOccurrencesOfString:@"(" withString:@""];

    switch (indexPath.row) {
        case 0:
            phoneNumber =  [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactHomeAreaCode, self.currentJob.contactHomePhone]];
            break;
        case 1:
            phoneNumber =  [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactCellAreaCode, self.currentJob.contactCell]];
            break;
        case 2:
            phoneNumber =  [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactWorkAreaCode, self.currentJob.contactWorkPhone]];
            break;
        case 3:
            phoneNumber =  [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.contactPagerAreaCode, self.currentJob.contactPagerPhone]];
            break;
       
        case 4:
            phoneNumber =  [NSMutableString stringWithString:[NSString stringWithFormat:@"(%@) %@", self.currentJob.onSiteContactAreaCode, self.currentJob.onSiteContactPhone]];
            break;
            
        default:
            break;
    }
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"Ext:" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"null" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([phoneNumber length] > 6)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", phoneNumber]]];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setupMenuBarButtonItems {
    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editMode:)];
}

- (IBAction)editMode:(id)sender
{
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self savePhoneNumbers:nil];
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];

        [self.tableView setEditing:NO animated:YES];
        [self.tableView reloadData];
     //   [self.editButtonsetTitle:@"Edit"forState:UIControlStateNormal];
    }
    else {
       // [self.editButtonsetTitle:@"Done"forState:UIControlStateNormal];
        
        // Turn on edit mode
        [self.navigationItem.rightBarButtonItem setTitle:@"Save"];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadData];

    }}


@end
