//
//  MJNotificationsTableViewController.m
//  GOT-JUNK
//
//  Created by David Block on 2015-04-08.
//  Copyright (c) 2015 David Block. All rights reserved.
//

#import "MJNotificationsTableViewController.h"
#import "MJNotificationCell.h"
#import "DataStoreSingleton.h"
#import "Notification.h"
#import "FetchHelper.h"
#import "MBProgressHUD.h"
#import "RouteListViewController.h"
#import "MJJobDetailViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "UserDefaultsSingleton.h"

@interface MJNotificationsTableViewController ()
{
    UIActivityIndicatorView *spinner;
}
@end

@implementation MJNotificationsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNotificationsComplete) name:@"FetchNotificationsComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNotificationsFailed) name:@"FetchNotificationsFailed" object:nil];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner stopAnimating];
    spinner.hidesWhenStopped = YES;
    spinner.frame = CGRectMake(0, 0, 320, 44);
    self.tableView.tableFooterView = spinner;
}

- (UIBarButtonItem *)leftMenuBarButtonItem
{
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (void)setupMenuBarButtonItems
{
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (void)leftSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^
     {
         [self setupMenuBarButtonItems];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getNotifications];
}

- (void)getNotifications
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FetchHelper sharedInstance] fetchNotifications];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance)
    {
        [self refreshBottom];
        [spinner startAnimating];
    }
}

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    //create the image for your button, and set the frame for its size
    UIImage *image = [UIImage imageNamed:@"route.png"];
    CGRect frame = CGRectMake(0, 0, 25, 25);
    
    //init a normal UIButton using that image
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    //set the button to handle clicks - this one calls a method called 'downloadClicked'
    [button addTarget:self action:@selector(filterButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    //finally, create your UIBarButtonItem using that button
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    return barButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)filterButtonPressed
{
    RouteListViewController *vc = [[RouteListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc setRequiresBack:YES];
}

- (void)fetchNotificationsComplete
{
    [spinner stopAnimating];
    [self.refreshControl endRefreshing];

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    [self.tableView reloadData];
}

- (void)fetchNotificationsFailed
{
    [spinner stopAnimating];
    [self.refreshControl endRefreshing];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"1-800-GOT-JUNK" message:@"Error retreiving notification history" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [av show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[DataStoreSingleton sharedInstance].notificationList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *note = [[DataStoreSingleton sharedInstance].notificationList objectAtIndex:indexPath.row];

    return 21.f + note.textHeight + 15.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MJNotificationCell";
    MJNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MJNotificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell...
    Notification *note = [[DataStoreSingleton sharedInstance].notificationList objectAtIndex:indexPath.row];
    NSString *noteMode = note.notificationModeText? note.notificationModeText : @"";
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ - %@", note.notificationDateDisplay, noteMode];
    cell.detailView.text = note.notificationText;
    [cell.detailView setFrame:CGRectMake(cell.detailView.frame.origin.x, cell.titleLabel.frame.size.height, cell.detailView.frame.size.width, note.textHeight + 15.f)];
    
    //cell.borderView.hidden = !note.isJobViewable;
    if(!note.isJobViewable){
        // GREY OUT
        cell.borderView.hidden = YES;
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    
    [cell.borderView setFrame:CGRectMake(1, 1, 318, 21.f + note.textHeight + 14.f)];
    [cell.acceptedImage setHidden:!note.isAccepted];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *note = [[DataStoreSingleton sharedInstance].notificationList objectAtIndex:indexPath.row];
    return note.isJobViewable;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *note = [[DataStoreSingleton sharedInstance].notificationList objectAtIndex:indexPath.row];
    if( note.jobID > 0 && note.isJobViewable == YES)
    {
        Job* job = [[DataStoreSingleton sharedInstance] getJob:note.jobID];
        if( job != nil )
        {
            MJJobDetailViewController *detailViewController = [[MJJobDetailViewController alloc] initWithJob:job];
    
            // Push the view controller.
            [self.navigationController pushViewController:detailViewController animated:YES];
        }
        else
        {
            [[UserDefaultsSingleton sharedInstance] setJobToView:[NSString stringWithFormat:@"%d", note.jobID]];
            [[FetchHelper sharedInstance] fetchJobDetaislForJob:[NSNumber numberWithInteger:note.jobID]];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)refresh:(UIRefreshControl *)sender
{
    [[DataStoreSingleton sharedInstance] decrementCurrentNotificationPageNumber];
    [self getNotifications];
}

- (void)refreshBottom
{
    [[DataStoreSingleton sharedInstance] incrementCurrentNotificationPageNumber];
    [self getNotifications];
}

@end
