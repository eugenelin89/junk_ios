//
//  SendInvoiceViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"

#import "SendInvoiceViewController.h"

#import "DataStoreSingleton.h"
#import "FetchHelper.h"
#import "Job.h"
#import "MoneyHelper.h"
#import "PaymentMethod.h"
#import "TaxType.h"


@interface SendInvoiceViewController ()

@end

@implementation SendInvoiceViewController

@synthesize invoiceNumberContainerView = _invoiceNumberContainerView;
@synthesize invoiceNumberTF = _invoiceNumberTF;
@synthesize detailsContainerView = _detailsContainerView;
@synthesize methodTF = _methodTF;
@synthesize priceTF = _priceTF;
@synthesize discountTF = _discountTF;
@synthesize salesTaxTF = _salesTaxTF;
@synthesize totalTF = _totalTF;
@synthesize doneButton = _doneButton;
@synthesize pickerView = _pickerView;
@synthesize job = _job;
@synthesize taxList = _taxList;
@synthesize formContainer = _formContainer;

- (id)initWithJob:(Job*)job
{
  self = [super initWithNibName: @"SendInvoiceViewController" bundle: nil];
  if (self) {
    self.job = job;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTaxList) name:@"FetchTaxListComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPaymentMethod) name:@"PaymentMethodListComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendInvoiceCompletedSuccessful) name:@"SendInvoiceCompleteSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendInvoiceCompletedFailure) name:@"SendInvoiceCompleteFailure" object:nil];
  }

  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  [self setupNavBar];
  [self setFooter];
  [self renderView];

  self.doneButton.enabled = NO;

  [self setupGestures];

  _pickerViewType = @"PaymentMethod";

}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear: animated];

  [self getPaymentMethods];
  [self getTaxTypes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UI

- (void)setupNavBar
{
  self.title = @"Payment Details";

  UIImage *buttonImage = [[UIImage imageNamed:@"navbar-button-blue-back.png"]
                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 5)];
  UIImage *buttonImageHighlight = [[UIImage imageNamed:@"navbar-button-blue-back-press.png"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 5)];

  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
  [backButton setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  [backButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
  self.navigationItem.leftBarButtonItem = backButton;
}

- (void)setFooter
{
  self.footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar.png"]];

  UIImage *buttonImage = [[UIImage imageNamed:@"button-green.png"]
                          resizableImageWithCapInsets:UIEdgeInsetsMake(24, 8, 24, 8)];
  UIImage *buttonImageHighlight = [[UIImage imageNamed:@"button-green-press.png"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];

  [self.doneButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
  [self.doneButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)renderView
{
  self.view.backgroundColor = [UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1.0];

  self.invoiceNumberContainerView.layer.cornerRadius = 10;
  self.invoiceNumberContainerView.layer.borderWidth = 1;
  self.invoiceNumberContainerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];

  self.detailsContainerView.layer.cornerRadius = 10;
  self.detailsContainerView.layer.borderWidth = 1;
  self.detailsContainerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

# pragma mark - HTTP Requests

- (void)getPaymentMethods
{
  [[FetchHelper sharedInstance] fetchPaymentMethods];
}

- (void)getTaxTypes
{
  [[FetchHelper sharedInstance] fetchTaxTypes];
}

- (void)loadPaymentMethod
{
  self.paymentMethodList = [[DataStoreSingleton sharedInstance] paymentMethodList];
}

- (void)sendInvoice:(Job *)job
      paymentMethod:(NSInteger)paymentID
         junkCharge:(NSInteger)junkCharge
           discount:(NSInteger)discount
      invoiceNumber:(NSInteger)invoiceNumber
              taxID:(NSInteger)taxID
{
    [[FetchHelper sharedInstance] sendInvoice:job
                                paymentMethod:paymentID
                                   junkCharge:junkCharge
                                     discount:discount
                                invoiceNumber:invoiceNumber
                                        taxID:taxID];
}

# pragma mark - Button IBActions

- (IBAction)sendInvoiceWasPressed:(id)sender
{
    [self sendInvoiceAction];
}

- (IBAction)paymentMethodPressed:(id)sender
{
//  _pickerViewType = @"PaymentMethod";
//  [self showPickerView];
}

- (IBAction)taxTypePressed:(id)sender
{
//  _pickerViewType = @"TaxType";
//  [self showPickerView];
}

# pragma mark - UIPickerView Delegate Datasource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  if ([_pickerViewType isEqualToString:@"PaymentMethod"])
  {
    return [self.paymentMethodList count];
  }
  else
  {
    return [self.taxList count];
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
  return 44;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  if ([_pickerViewType isEqualToString:@"PaymentMethod"])
  {
    PaymentMethod *pm = [self.paymentMethodList objectAtIndex:row];
    return pm.paymentName;
  }
  else
  {
    TaxType *tax = [self.taxList objectAtIndex:row];
    return tax.taxValue;
  }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  if ([_pickerViewType isEqualToString:@"PaymentMethod"])
  {
    PaymentMethod *pm = [self.paymentMethodList objectAtIndex:row];
    self.methodTF.text = pm.paymentName;
    _selectedPaymentMethod = pm;
  }
  else
  {
    TaxType *tax = [self.taxList objectAtIndex:row];
    self.salesTaxTF.text = tax.taxValue;
    _selectedTaxType = tax;
  }
  [self hidePickerView];
}

- (void)showPickerView
{
  [self.pickerView reloadAllComponents];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.5];
  CGRect frame = self.pickerView.frame;
  frame.origin.y = self.view.frame.size.height - 216;
  self.pickerView.frame = frame;
  [UIView commitAnimations];
}

- (void)hidePickerView
{
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:.5];
  CGRect frame = self.pickerView.frame;
  frame.origin.y = self.view.frame.size.height;
  self.pickerView.frame = frame;
  [UIView commitAnimations];

  if ([self allTextFieldsAreFilled])
  {
    self.doneButton.enabled = YES;
  }
}

- (void)loadTaxList
{
  self.taxList = [[DataStoreSingleton sharedInstance] taxList];

  //NSArray *tarray = @[@"one", @"two", @"three", @"four"];

  if (!self.taxActionSheet)
  {
    //char *argList = (char *)malloc(sizeof(NSString *) * [tarray count]);
    //id argListObjects = CFBridgingRetain((__bridge)argList);
    //[tarray getObjects:(id *)argList];

    //contents = [[NSString alloc] initWithFormat:formatString arguments:argList];

    self.taxActionSheet = [[UIActionSheet alloc] initWithTitle:@"Tax Type"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];

    for (TaxType *tax in self.taxList)
    {
      NSLog(@"taxID: %d, tax-value: %@", [tax.taxId integerValue], tax.taxValue);
      [self.taxActionSheet addButtonWithTitle:tax.taxValue];
    }
    [self.taxActionSheet addButtonWithTitle:@"Cancel"];
  }

  [self populateInitialValues];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet == self.taxActionSheet)
  {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
    {
      [self.taxActionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else
    {
      TaxType *tax = [self.taxList objectAtIndex:buttonIndex];
      self.salesTaxTF.text = tax.taxValue;
      _selectedTaxType = tax;
      self.totalTF.text = [self calculateTotalWithPrice:self.priceTF.text tax:tax.taxValue discount:self.discountTF.text];
    }
  }
}

# pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//  if (textField == self.invoiceNumberTF)
//  {
//    [self.invoiceNumberTF resignFirstResponder];
//    _pickerViewType = @"PaymentMethod";
//    [self showPickerView];
//  }
//  else if (textField == self.priceTF)
//  {
//    [self.priceTF resignFirstResponder];
//    [self.discountTF becomeFirstResponder];
//  }
//  else if (textField == self.discountTF)
//  {
//    [self.discountTF resignFirstResponder];
//    _pickerViewType = @"TaxType";
//    [self showPickerView];
//  }

  [textField resignFirstResponder];

  return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  if ([UIScreen mainScreen].bounds.size.height == 568.0)
  {
    // if user is on iphone 5

    self.formContainer.contentSize = CGSizeMake(self.formContainer.frame.size.width, self.formContainer.frame.size.height + 84);

    if (textField != self.invoiceNumberTF)
    {
      self.formContainer.contentOffset = CGPointMake(0, 84);
    }
  }
  else
  {
    // user is on 3.5 inch iphone
    self.formContainer.contentSize = CGSizeMake(self.formContainer.frame.size.width, self.formContainer.frame.size.height + 160);

    if (textField != self.invoiceNumberTF)
    {
      self.formContainer.contentOffset = CGPointMake(0, 160);
    }
  }

  if (textField == self.salesTaxTF)
  {
    if (_currentTextField)
    {
      [_currentTextField resignFirstResponder];
    }
    [self.taxActionSheet showInView:self.view];
    return NO;
  }
  else if (textField == self.methodTF)
  {
    if (_currentTextField)
    {
      [_currentTextField resignFirstResponder];
    }
    _pickerViewType = @"PaymentMethod";
    [self showPickerView];
    return NO;
  }

  _currentTextField = textField;
  [self hidePickerView];
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  [textField resignFirstResponder];

  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  // if editing the price or discount textfields, update the total textfield
  if (textField != self.invoiceNumberTF && textField != self.methodTF)
  {
    NSLog(@"current text: %@, replacement string: %@, range: %d", textField.text, string, range.location);
    NSString *text = @"";

    if ([string isEqualToString:@""])
    {
      text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    else
    {
      if (range.location == 0)
      {
        text = [NSString stringWithFormat:@"%@%@", string, textField.text];
      }
      else if (range.location == [textField.text length])
      {
        text = [NSString stringWithFormat:@"%@%@", textField.text, string];
      }
      else
      {
        NSString *beginingString = [textField.text substringToIndex:range.location];
        NSString *endingString = [textField.text substringFromIndex:range.location];
        text = [NSString stringWithFormat:@"%@%@%@", beginingString, string, endingString];
      }
    }

    if (textField == self.priceTF)
    {
      self.totalTF.text = [self calculateTotalWithPrice:text tax:self.salesTaxTF.text discount:self.discountTF.text];
      if ([self allTextFieldsAreFilled] && ![text isEqualToString:@""])
      {
        self.doneButton.enabled = YES;
      }
      else
      {
        self.doneButton.enabled = NO;
      }
    }
    else if (textField == self.discountTF)
    {
      self.totalTF.text = [self calculateTotalWithPrice:self.priceTF.text tax:self.salesTaxTF.text discount:text];
    }

  }
  else if (textField == self.invoiceNumberTF)
  {
    if (![self.invoiceNumberTF.text isEqualToString:@""] && ![string isEqualToString:@""])
    {
      self.doneButton.enabled = YES;
    }
    else
    {
      self.doneButton.enabled = NO;
    }
  }

  return YES;
}

- (BOOL)allTextFieldsAreFilled
{
  if ([self.invoiceNumberTF.text isEqualToString:@""])
  {
    return NO;
  }
  else if ([self.methodTF.text isEqualToString:@""])
  {
    return NO;
  }
  else if ([self.priceTF.text isEqualToString:@""])
  {
    return NO;
  }
  else if ([self.salesTaxTF.text isEqualToString:@""])
  {
    return NO;
  }
  else
  {
    return YES;
  }
}

- (NSString *)calculateTotalValue
{

  if ([self.priceTF.text isEqualToString:@""] || [self.priceTF.text integerValue] == 0)
  {
    return @"0.00";
  }
  else
  {
    NSDecimalNumber *discountAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *priceAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *salesTaxAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    if (![self.discountTF.text isEqualToString:@""])
    {
      discountAsDecimal = [NSDecimalNumber decimalNumberWithString:self.discountTF.text];
    }

    if (![self.priceTF.text isEqualToString:@""])
    {
      priceAsDecimal = [NSDecimalNumber decimalNumberWithString:self.priceTF.text];
    }

    if (![self.salesTaxTF.text isEqualToString:@""])
    {
      salesTaxAsDecimal = [NSDecimalNumber decimalNumberWithString:self.salesTaxTF.text];
    }


    NSDecimalNumber *dec = [salesTaxAsDecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
    NSDecimalNumber *priceDiscountSum = [priceAsDecimal decimalNumberBySubtracting:discountAsDecimal];
    dec = [dec decimalNumberByMultiplyingBy:priceDiscountSum];

    NSDecimalNumber *total = [dec decimalNumberByAdding:priceDiscountSum];

    return [NSString stringWithFormat:@"%.02f", [total floatValue]];
  }
}

- (NSString*)calculateTotalWithPrice:(NSString*)price tax:(NSString*)tax discount:(NSString*)discount
{
  if ([price isEqualToString:@""] || [price integerValue] == 0)
  {
    return @"0.00";
  }
  else
  {
    NSDecimalNumber *discountAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *priceAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    NSDecimalNumber *salesTaxAsDecimal = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    if (![discount isEqualToString:@""])
    {
      discountAsDecimal = [NSDecimalNumber decimalNumberWithString:discount];
    }

    if (![price isEqualToString:@""])
    {
      priceAsDecimal = [NSDecimalNumber decimalNumberWithString:price];
    }

    if (![tax isEqualToString:@""])
    {
      salesTaxAsDecimal = [NSDecimalNumber decimalNumberWithString:tax];
      NSLog(@"sales tax: %f", [salesTaxAsDecimal floatValue]);
    }


    NSDecimalNumber *dec = [salesTaxAsDecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
    NSDecimalNumber *priceDiscountSum = [priceAsDecimal decimalNumberBySubtracting:discountAsDecimal];
    dec = [dec decimalNumberByMultiplyingBy:priceDiscountSum];

    NSDecimalNumber *total = [dec decimalNumberByAdding:priceDiscountSum];

    return [NSString stringWithFormat:@"%.02f", [total floatValue]];
  }
}

# pragma mark - Gesutre Recognizer

- (void)setupGestures
{
  UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
  recognizer.delegate = self;
  [recognizer setNumberOfTapsRequired:1];
  recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
  [self.formContainer addGestureRecognizer:recognizer];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
  if (_currentTextField)
  {
    [_currentTextField resignFirstResponder];
    self.formContainer.contentSize = CGSizeMake(self.formContainer.frame.size.width, self.formContainer.frame.size.height);
  }

  [self hidePickerView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  NSLog(@"touch class: %@", [touch.view class]);
//  NSString *classAsString = [NSString stringWithFormat:@"%@", [touch.view class]];

  return  YES;
}

- (void)popViewController
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendInvoiceCompletedSuccessful
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];

  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Sent" message:@"Payment details stored in JunkNet" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
  [av show];
}

- (void)sendInvoiceCompletedFailure
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];

  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Failed" message:@"Payment details were unable to be sent. Please try again." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
  [av show];
}

# pragma mark - Key Methods

- (void)sendInvoiceAction
{
  if ([self allTextFieldsAreFilled])
  {
      NSInteger junkCharge = [MoneyHelper moneyStringToCents: self.priceTF.text];
      NSInteger discount   = [MoneyHelper moneyStringToCents: self.discountTF.text];

      [self sendInvoice:self.job
          paymentMethod:[_selectedPaymentMethod.paymentID integerValue]
             junkCharge:junkCharge
               discount:discount
          invoiceNumber:[self.invoiceNumberTF.text integerValue]
                  taxID:[_selectedTaxType.taxId integerValue]];


      [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  } else {
      // Should we say something here?
  }
}

- (void)populateInitialValues
{
  if (![self.job.invoiceNumber isEqualToString:@""])
  {
    self.invoiceNumberTF.text = self.job.invoiceNumber;
  }

  if (self.job.paymentID)
  {
    for (PaymentMethod *pm in self.paymentMethodList)
    {
      if ([self.job.paymentID integerValue] == [pm.paymentID integerValue])
      {
        self.methodTF.text = pm.paymentName;
        _selectedPaymentMethod = pm;
        break;
      }
    }
  }

  if ([self.job.subTotal integerValue] != 0)
  {
    NSInteger dollars = [self.job.subTotal integerValue]/100;
    NSInteger cents = [self.job.subTotal integerValue]%100;
    NSString *centsAsString = @"00";
    if (cents < 10)
    {
      centsAsString = [NSString stringWithFormat:@"0%d", cents];
    }
    else
    {
      centsAsString = [NSString stringWithFormat:@"%d", cents];
    }
    self.priceTF.text = [NSString stringWithFormat:@"%d.%@", dollars, centsAsString];
  }
  else
  {
    self.priceTF.text = @"";
  }

  if ([self.job.discount integerValue] != 0)
  {
    NSInteger dollars = [self.job.discount integerValue]/100;
    NSInteger cents = [self.job.discount integerValue]%100;
    NSString *centsAsString = @"00";
    if (cents < 10)
    {
      centsAsString = [NSString stringWithFormat:@"0%d", cents];
    }
    else
    {
      centsAsString = [NSString stringWithFormat:@"%d", cents];
    }
    self.discountTF.text = [NSString stringWithFormat:@"%d.%@", dollars, centsAsString];
  }
  else
  {
    self.discountTF.text = @"";
  }

  if (self.job.taxID)
  {
    for (TaxType *tt in self.taxList)
    {
      if ([self.job.taxID integerValue] == [tt.taxId integerValue])
      {
        self.salesTaxTF.text = tt.taxValue;
        _selectedTaxType = tt;
        break;
      }
    }
  }


  self.totalTF.text = [self calculateTotalValue];
}

@end
