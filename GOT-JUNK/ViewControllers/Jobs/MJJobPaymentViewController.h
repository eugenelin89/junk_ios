//
//  MJJobPaymentViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-02.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

@interface MJJobPaymentViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong) Job * currentJob;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) IBOutlet UIButton * taxButton;

@property (nonatomic, strong) IBOutlet UITextField * activeField;

@property (nonatomic, strong) IBOutlet UITextField * invoiceField;
@property (nonatomic, strong) IBOutlet UITextField * discountField;
@property (nonatomic, strong) IBOutlet UITextField * totalField;
@property (nonatomic, strong) IBOutlet UITextField * junkChargeField;
@property int taxID;
@property float taxAmount;


@property (nonatomic, strong) NSMutableArray * paymentsArray;
- (IBAction)showTaxList:(id)sender;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
- (IBAction)addPayment:(id)sender;
- (IBAction)editPayments:(id)sender;

- (IBAction)calculateTotal:(id)sender;

@end
