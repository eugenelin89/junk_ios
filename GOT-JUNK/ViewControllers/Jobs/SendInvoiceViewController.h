//
//  SendInvoiceViewController.h
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Job, TaxType, PaymentMethod;

@interface SendInvoiceViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
{
  @private
  NSString *_pickerViewType;
  TaxType *_selectedTaxType;
  PaymentMethod *_selectedPaymentMethod;
  UITextField *_currentTextField;
}

@property (nonatomic, strong) IBOutlet UIView *invoiceNumberContainerView;
@property (nonatomic, strong) IBOutlet UITextField *invoiceNumberTF;
@property (nonatomic, strong) IBOutlet UIView *detailsContainerView;
@property (nonatomic, strong) IBOutlet UITextField *methodTF;
@property (nonatomic, strong) IBOutlet UITextField *priceTF;
@property (nonatomic, strong) IBOutlet UITextField *discountTF;
@property (nonatomic, strong) IBOutlet UITextField *salesTaxTF;
@property (nonatomic, strong) IBOutlet UITextField *totalTF;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIScrollView *formContainer;
@property (strong) IBOutlet UIView *footerView;
@property (nonatomic, strong) Job *job;
@property (nonatomic, strong) NSArray *taxList;
@property (nonatomic, strong) NSArray *paymentMethodList;
@property (nonatomic, strong) UIActionSheet *taxActionSheet;

- (IBAction)sendInvoiceWasPressed:(id)sender;
- (IBAction)paymentMethodPressed:(id)sender;
- (IBAction)taxTypePressed:(id)sender;

- (id)initWithJob:(Job*)job;

@end
