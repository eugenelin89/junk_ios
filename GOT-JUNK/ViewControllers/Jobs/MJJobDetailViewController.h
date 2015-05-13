//
//  MJJobDetailViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-29.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Job.h"
@interface MJJobDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableView *NPSTableView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) Job *currentJob;
@property (nonatomic, strong) IBOutlet UILabel *customerNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *enviroLabel;

@property (nonatomic, strong) IBOutlet UILabel *customerCompanyLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UITextView *notesField;
@property (nonatomic, strong) IBOutlet UIButton *callStatusButton;
@property (nonatomic, strong) IBOutlet UIButton *paymentStatusButton;
@property (nonatomic, strong) IBOutlet UIButton *moveAdjustButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *enviroButton;
@property (nonatomic, strong) IBOutlet UIImageView *jobImageType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightCon;
@property (weak, nonatomic) IBOutlet UIView *dispatchView;

@property int indexJob;
@property BOOL calling;
- (id)initWithJob:(Job*)job;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
- (IBAction)cancelJob:(id)sender;
- (IBAction)editJob:(id)sender;
- (IBAction)pressPayment:(id)sender;
- (IBAction)pushNoteController:(id)sender;

@end
