//
//  MJJobPaymentDetailViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-02.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payment.h"
#import "Job.h"
@interface MJJobPaymentDetailViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Payment * currentPayment;
@property int currentIndex;
@property int methodID;
@property float remainingAmount;
@property (strong) Job * currentJob;
- (IBAction)addPayment:(id)sender;
- (IBAction)showExpensePaymentMethodsList:(id)sender;
@property (nonatomic, strong) IBOutlet UILabel * amountLabel;
@property (nonatomic, strong) IBOutlet UITextField * paymentField;
@property (nonatomic, strong) IBOutlet UIButton * paymentTypeButton;

@end
