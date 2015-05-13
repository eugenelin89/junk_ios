//
//  JNExpenseDetailViewController.h
//  Example
//
//  Created by Mark Pettersson on 2013-07-16.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Expense.h"
#import "MapPoint.h"
#import "Resource.h"

@interface JNExpenseDetailViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, MKMapViewDelegate, UIScrollViewDelegate>


@property (strong) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet MKMapView * map;
@property (retain, nonatomic) IBOutlet UISwitch * saveLocationSwitch;
@property (retain, nonatomic) IBOutlet UIButton * showMapButton;
@property (strong) IBOutlet UITextField *tickettextField;
@property (strong) IBOutlet UITextField *amounttextField;
@property (strong) IBOutlet UITextField *descriptionTextField;
@property (strong) IBOutlet UILabel *totalLabel;

@property (strong) IBOutlet UILabel *expenseAccountName;
@property (strong) IBOutlet UILabel *expenseType;
@property (strong) IBOutlet UILabel *expensePaymentMethodName;
@property (strong) IBOutlet UILabel *expenseTaxName;

@property (strong) IBOutlet UILabel *descriptionLabel;


@property (strong) IBOutlet UIButton *submitButton;

@property (strong) IBOutlet UIButton *taxButton;
@property (strong) IBOutlet UIButton *accountButton;
@property (strong) IBOutlet UIButton *paymentMethodButton;

@property (strong, nonatomic) Expense *myExpense;
@property (strong, nonatomic) Resource *myResource;

@property BOOL userLocationUpdated;
@property MKUserLocation * userLocation;
@property MapPoint * myPin;
@property BOOL isMapVisible;

- (IBAction)showExpenseAccountsList:(id)sender;
- (IBAction)showExpensePaymentMethodsList:(id)sender;
- (IBAction)showTaxList:(id)sender;
- (IBAction)calculateTotal:(id)sender;
- (IBAction)saveExpense:(id)sender;
- (IBAction)removeKeyboard;
- (IBAction)showMap:(id)sender;
@end
