//
//  JNExpenseDetailViewController.m
//  Example
//
//  Created by Mark Pettersson on 2013-07-16.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MJResourceListViewController.h"
#import "JNExpenseDetailViewController.h"
#import "LookupTableViewController.h"
#import "UserDefaultsSingleton.h"
#import "MBProgressHUD.h"
#import "APIDataConversionHelper.h"
#import "APIObjectConversionHelper.h"

#import "DateHelper.h"
#import "DataStoreSingleton.h"
#import "ValidateHelper.h"
#import "Route.h"
#import "Flurry.h"
#import "MapPoint.h"
#import "FetchHelper.h"

typedef NS_ENUM(NSInteger, ExecutionState){
    ExecutionStateOff,
    ExecutionStateExecuting,
    ExecutionStateSuccess,
    ExecutionStateFailure
};

@interface JNExpenseDetailViewController ()

@property (nonatomic) ExecutionState saveExpenseState;
@property (nonatomic) ExecutionState saveResourceCoordinatesState;

@end

@implementation JNExpenseDetailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.saveExpenseState = ExecutionStateOff;
        self.saveResourceCoordinatesState = ExecutionStateOff;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Expense Details"];

    self.isMapVisible = NO;
    // Do any additional setup after loading the view from its nib.
    [self setLayout];
    [self setupNotifications];
    [self setupMenuBarButtonItems];
    [self setupMap];
    [self setInitialValues];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.tickettextField resignFirstResponder];
    [self.amounttextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createExpenseSuccessful) name:@"SendCreateExpenseSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createExpenseFailure) name:@"SendCreateExpenseFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpenseSuccessful) name:@"SendUpdateExpenseSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExpenseFailure) name:@"SendUpdateExpenseFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResourceSuccessful) name:@"SendUpdateResourceSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateResourceFailure) name:@"SendUpdateResourceFailure" object:nil];
}

- (void)setupMenuBarButtonItems {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveExpense:)];
}

- (IBAction)cancel:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setLayout
{
    self.title = @"Expense Detail";
    
    // set the expense type label
    NSString * expenseType = @"";
    BOOL showDescriptionField = NO;
    switch(self.myExpense.expenseTypeID){
        case 1:
            expenseType = @"Gas";
            break;
        case 2:
            expenseType = @"Disposal";
            break;
        default:
            expenseType = @"Miscellaneous";
            showDescriptionField = YES;
    }
    self.expenseType.text = expenseType;
    
    // set the borders on the buttons
    [self setButtonStyles:self.accountButton];
    [self setButtonStyles:self.paymentMethodButton];
    [self setButtonStyles:self.taxButton];
    
    // if not the miscellaneous expense type, then hide the description field
    if (!showDescriptionField){
        self.descriptionLabel.hidden = YES;
        self.descriptionTextField.hidden = YES;
    }
    
}

- (void)setButtonStyles:(UIButton *)btn
{
    btn.layer.cornerRadius = 5;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blueColor].CGColor;
}


- (void)setInitialValues
{
    if (self.myExpense)
    {
        self.expenseAccountName.text = self.myExpense.expenseAccount;
        self.tickettextField.text = self.myExpense.ticket;
        self.expensePaymentMethodName.text = self.myExpense.paymentMethod;
        self.amounttextField.text = [NSString stringWithFormat:@"%0.02f", (float)self.myExpense.subTotal / 100];
        self.expenseTaxName.text = [self.myExpense.tax stringByAppendingString:@" %"];
        self.totalLabel.text = [NSString stringWithFormat:@"%0.02f", (float)self.myExpense.total / 100];
        self.descriptionTextField.text = self.myExpense.expenseDescription;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [DataStoreSingleton sharedInstance].currentLookupMode = @"";
    [DataStoreSingleton sharedInstance].currentLookup = nil;
    
    self.scrollView.delegate = nil;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 900)];
    
    [self.scrollView setContentOffset:CGPointMake(0,260)];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    NSString *currentLookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
    Lookup *currentLookup = [[DataStoreSingleton sharedInstance] currentLookup];
    
    NSString *itemName = [[DataStoreSingleton sharedInstance] currentLookup].itemName;
    
    if([currentLookupMode isEqualToString:@"FRANCHISEEXPENSE"]){
        
        self.expenseAccountName.text = self.myResource.resourceName;
        self.myExpense.expenseAccountID = self.myResource.resourceID;
        self.myExpense.expenseAccount = self.myResource.resourceName;
        
        // let's update the map!
        // if the chosen location has a coord, then center the map there and pin the coords
        // else let's just reposition back on the user's current location and pin it.
        
        if ([self isValidCoordsForLat:self.myResource.latitude andLng:self.myResource.longitude]){
            
            [self refocusMapOnLat:self.myResource.latitude andLng:self.myResource.longitude];
            
        } else if (self.userLocation) {
            
            [self refocusMapOnLat:self.userLocation.coordinate.latitude andLng:self.userLocation.coordinate.longitude];
        }
        
    } else if ([currentLookupMode isEqualToString:@"PAYMENTMETHODEXPENSE"]){
        self.expensePaymentMethodName.text = itemName;
        
        self.myExpense.paymentMethod = currentLookup.itemName;
        self.myExpense.paymentMethodID = currentLookup.itemID;
        
    } else if ([currentLookupMode isEqualToString:@"TAXTYPE"]) {
        self.expenseTaxName.text = [itemName stringByAppendingString:@" %"];
        
        self.myExpense.tax = currentLookup.itemName;
        self.myExpense.taxID = currentLookup.itemID;
        
        // recalculate the total.
        [self calculateTotal:nil];
    }
}

- (BOOL)isValidCoordsForLat:(float)lat andLng:(float)lng {
    if (lng != 0 && lat != 0)
        return YES;
    else
        return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 * Rules:
 *  - these fields must be filled in
 *      - account
 *      - tax
 *      - ticket/receipt
 *      - payment method
 *      - subtotal
 *  - these fields must be numeric
 *      - subtotal
 */
- (BOOL)validateForm
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *errorMessage = [[NSString alloc] init];
    if (!self.myExpense.expenseAccountID){
        errorMessage = @"You must choose an account.";
    } else if (!self.myExpense.taxID){
        errorMessage = @"You must set a tax.";
    } else if (self.tickettextField.text.length == 0){
        errorMessage = @"You must enter a ticket/receipt number.";
    } else if (!self.myExpense.paymentMethodID){
        errorMessage = @"You must choose a payment method.";
    } else if (self.amounttextField.text.length == 0){
        errorMessage = @"You must set the job amount.";
    }
    
    // subtotal field must be numeric
    if (![ValidateHelper valNumeric:self.amounttextField.text] || [self.amounttextField.text floatValue] <= 0){
        errorMessage = @"You must input a positive numeric job amount.";
    }
    
    if (errorMessage.length > 0){
        
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"Error"
                           message:errorMessage
                           delegate:self
                           cancelButtonTitle:@"Close"
                           otherButtonTitles: nil];
        [av show];
        return NO;
    } else {
        return YES;
    }
    
}



#pragma mark Event handlers and supporting functions


- (IBAction)showMap:(UIButton *)sender
{
    if (self.isMapVisible){ // map is already showing, so hide the map
        [sender setTitle:@"Show Map" forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
        self.isMapVisible = NO;

    } else { // map is hidden, so now let's show it
        [sender setTitle:@"Hide Map" forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];
        self.isMapVisible = YES;
    }
    
    /*
    if ([sender.currentTitle isEqualToString:@"Show Map"]){
        [sender setTitle:@"Hide Map" forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(0, -64) animated:YES];
        
    } else { // label is "hide map"
        [sender setTitle:@"Show Map" forState:UIControlStateNormal];
        [self.scrollView setContentOffset:CGPointMake(0, 260) animated:YES];
    }
     */
    
}


// make the keyboard go away
- (IBAction)removeKeyboard
{
    [self.amounttextField resignFirstResponder];
}


- (IBAction)showExpenseAccountsList:(id)sender
{
    MJResourceListViewController * vc = [[MJResourceListViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.mode = @"FRANCHISEEXPENSE";
    vc.itemID = self.myExpense.expenseTypeID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showExpensePaymentMethodsList:(id)sender
{
    [self showListView:@"PAYMENTMETHODEXPENSE" itemID:0];
}

- (IBAction)showTaxList:(id)sender
{
    [self showListView:@"TAXTYPE" itemID:0];
}

- (void)showListView:(NSString *)mode itemID:(int)i
{
    LookupTableViewController *vc = [[LookupTableViewController alloc] init];
    vc.mode = mode;
    vc.itemID = i;
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}



// fired when user changes tax or enters a digit in the Amount textfield
- (IBAction)calculateTotal:(id)sender
{
    // total = subtotal + (subtotal * tax * 0.01)
    
    float subtotal = [self.amounttextField.text floatValue];
    float tax = [self.myExpense.tax floatValue];
    
    float total = subtotal + (subtotal * tax * 0.01);
    
    self.totalLabel.text = [NSString stringWithFormat:@"%.02f", total];
    
}

#pragma mark Save the expense

// clicking on the Save button
- (IBAction)saveExpense:(id)sender
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self dismissKeyboard];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // perform validation first
    if (![self validateForm])
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
  
        return;
    }
    
    // set the states to indicate that we're about to submit the data
    self.saveExpenseState = ExecutionStateExecuting;
    
    
    // we set the state for the resource coordinates saving *before* we run submitExpense,
    // because we want to avoid situation where submitExpense completes execution before we have a chance to start
    // running submitResourceCoordinates.
    // if this happeneed, we would be bringing up the success message prematurely.
    if ([self.saveLocationSwitch isOn]){
        self.saveResourceCoordinatesState = ExecutionStateExecuting;
    }
    
    [self submitExpense];
    
    if ([self.saveLocationSwitch isOn]){
        [self submitResourceCoordinates];
    }
    
}

- (void)submitExpense
{
    BOOL bCreate = NO; // no means we're just doing an update
    Expense * thisExpense = [[Expense alloc] init];
    
    // if expenseID is defined, then we're just doing an update
    if (!self.myExpense.expenseID || self.myExpense.expenseID == 0){
        bCreate = YES;
    }
    
    // account
    thisExpense.expenseAccount = self.myExpense.expenseAccount;
    thisExpense.expenseAccountID = self.myExpense.expenseAccountID;
    
    // expense type
    thisExpense.expenseTypeID = self.myExpense.expenseTypeID;
    
    // ticket/receipt
    thisExpense.ticket = self.tickettextField.text;
    
    // payment method
    thisExpense.paymentMethodID = self.myExpense.paymentMethodID;
    
    // subtotal (multiply by 100 so we can preserve decimal values when passing data to the API)
    thisExpense.subTotal = [self.amounttextField.text floatValue] * 100;
    
    // tax
    thisExpense.taxID = self.myExpense.taxID;
    
    // description
    NSString *description = self.descriptionTextField.text;
    if (!description){
        description = @"";
    }
    
    
    
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    
    
    // normalize a few input parameters
    NSNumber *routeID;
    
    if ([[DataStoreSingleton sharedInstance] currentRoute])
    {
        routeID = [[DataStoreSingleton sharedInstance] currentRoute].routeID;
    } else
    {
        routeID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
    }
    
    
    NSString *path = [[NSString alloc] init];
    
    // set the parameters to be posted
    // expenseID, franchiseExpenseID, paymentTypeID, taxID, invoiceNo, description, subTotal, isDelete
    
    int expenseID = 0;
    if (self.myExpense.expenseID)
    {
        expenseID = self.myExpense.expenseID;
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", expenseID], @"expenseID",
                            [NSString stringWithFormat:@"%d", thisExpense.expenseAccountID], @"accountID",
                            [NSString stringWithFormat:@"%d", thisExpense.expenseTypeID], @"expenseTypeID",
                            [NSString stringWithFormat:@"%d", thisExpense.paymentMethodID], @"paymentMethodID",  // thisExpense.paymentMethodID,
                            [NSString stringWithFormat:@"%d", thisExpense.taxID], @"taxID",
                            thisExpense.ticket, @"ticket",
                            description, @"description",
                            [NSString stringWithFormat:@"%d", thisExpense.subTotal], @"subTotal",
                            NO, @"isDelete",
                            nil];
    
    // execute the POST or the PUT
    if (bCreate == YES)
    {
        path = [NSString stringWithFormat:@"v1/Expense?sessionID=%@&dayID=%@&routeID=%d",
                sessionID,
                [DateHelper dateToApiString:currentDate],
                [routeID integerValue]];
        
        [[FetchHelper sharedInstance] postExpense:path withParams:params];
    }
    else
    {
        path = [NSString stringWithFormat:@"v1/Expense/%d?sessionID=%@&dayID=%@&routeID=%d&expenseTypeID=%d",
                self.myExpense.expenseID,
                sessionID,
                [DateHelper dateToApiString:currentDate],
                [routeID integerValue],
                self.myExpense.expenseTypeID];
        
        [[FetchHelper sharedInstance] putExpenseResource:path withParams:params withMode:SubmitModeExpense];
    }
    
}

- (void)submitResourceCoordinates
{
    // if valid, then let's save it
    MapPoint * pin = [self getPinFromMap];
    
    if (CLLocationCoordinate2DIsValid(pin.coordinate)){
        NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
        
        // get name of resource
        NSString * path = [NSString stringWithFormat:@"v1/Resource/%d?sessionID=%@", self.myResource.resourceID, sessionID];
        
        // get what should be the one and only annotation on the map
        NSPredicate * pred = [NSPredicate predicateWithFormat:@"class == %@", [MapPoint class]];
        NSArray * annotations = [self.map.annotations filteredArrayUsingPredicate:pred];
        
        if (annotations.count != 1) {
            NSLog(@"Expected to find 1 annotation, but found %d annotations instead.", annotations.count);
            self.saveResourceCoordinatesState = ExecutionStateOff;
            return;
        }
        
        MapPoint * point = (MapPoint *)([annotations objectAtIndex:0]);
        
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d", self.myResource.resourceID], @"resourceID",
                                [NSString stringWithFormat:@"%d", [APIDataConversionHelper convertCoordinateDataForSaving:point.coordinate.latitude]], @"latitude",
                                [NSString stringWithFormat:@"%d", [APIDataConversionHelper convertCoordinateDataForSaving:point.coordinate.longitude]], @"longitude",
                                nil];
        
        
        [[FetchHelper sharedInstance] putExpenseResource:path withParams:params withMode:SubmitModeResource];
    }
}

#pragma mark Map setup functions

- (void)setupMap
{
    self.map.frame = CGRectMake(0, 0, self.view.bounds.size.width, 220);
    [self.map setShowsUserLocation:YES];
    
    self.userLocationUpdated = NO;
    
    [self.scrollView addSubview:self.map];
    
}

- (MKMapView *)map{
    if(!_map){
        _map = [[MKMapView alloc] init];
    }
    return _map;
}

- (void)refocusMapOnLat:(float)latitude andLng:(float)longitude
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    [self.map setCenterCoordinate:coord animated:YES];
    
    CLLocationDistance regionWidth = 1500;
    CLLocationDistance regionHeight = 1500;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, regionWidth, regionHeight);
    
    [self.map setRegion:region animated:YES];
    
    // remove other annotations so that only this one is left.
    [self.map removeAnnotations:self.map.annotations];
    
    [self setDraggablePinOnLat:latitude andLng:longitude];
    
}

- (void)setDraggablePinOnLat:(float)latitude andLng:(float)longitude
{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    MapPoint * point = [[MapPoint alloc] initWithName:@"" address:@"" coordinate:coord];
    
    [self.map addAnnotation:point];
}

- (MapPoint *)getPinFromMap
{
    // attempt to get annotation from map (there should only be at most one)
    NSArray * annotations = self.map.annotations;
    MapPoint * point = nil;
    NSUInteger index = [annotations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[MapPoint class]];
    }];
    if (index != NSNotFound){ // found the pin
        point = [annotations objectAtIndex:index];
        NSLog(@"Lat: %f, Lng: %f", point.coordinate.latitude, point.coordinate.longitude);
        return point;
    }
    else {
        NSLog(@"Could not find a pin on the map!");
        return nil;
    }
}


#pragma mark UIScrollView delegates

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // if map is supposed to be hidden and user scrolls so that the map is even partially visible, scroll the user back down!
    if (!self.isMapVisible){
        if (scrollView.contentOffset.y < 200){
            [scrollView setContentOffset:CGPointMake(0, 200) animated:YES];
        }
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

#pragma mark MKMapView delegates



// center the map on my current location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.userLocationUpdated)
    {
        self.userLocationUpdated = YES;
        self.userLocation = userLocation;
        self.userLocation.title = @"";
        
        
        // determine whether to center the map on the user's current location, or the coordinates of the chosen resource
        CLLocationCoordinate2D startCenter;
        startCenter = userLocation.coordinate;
        
        // if new expense, just center the map on user's current location
        if (self.myExpense.expenseID == 0){
            
            CLLocationDistance regionWidth = 1500;
            CLLocationDistance regionHeight = 1500;
            MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, regionWidth, regionHeight);
            
            [self.map setRegion:startRegion animated:YES];
            
        }
        
        // otherwise if existing expense, check if the account has a defined set of coordinates.
        // if so, pin those coordinates. otherwise just pin the user's current location.
        else{
            
            // get our chosen resource!
            NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"resourceID = %d", self.myExpense.expenseAccountID]];
            
            Resource * expenseAccount = nil;
            NSArray * results = [[DataStoreSingleton sharedInstance].resourcesList filteredArrayUsingPredicate:predicate];
            if (results && results.count > 0) {
                expenseAccount = [results objectAtIndex:0];
                
                self.myResource = expenseAccount;
                float latitude = expenseAccount.latitude;
                float longitude = expenseAccount.longitude;
                
                // if valid coords, then let's plot it
                if ([self isValidCoordsForLat:latitude andLng:longitude]){
                    [self refocusMapOnLat:latitude andLng:longitude];
                } else {
                    [self refocusMapOnLat:startCenter.latitude andLng:startCenter.longitude];
                }

            }
        }
        
        
        
        //[self.scrollView addSubview:self.map];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"pin type: %@", NSStringFromClass([view class]));
}


// make my pin draggable and droppable
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.map dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    [pin setAnimatesDrop:NO];
    [pin setDraggable:YES];
    [pin setPinColor:MKPinAnnotationColorPurple];
    
    return pin;
}


- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding){
        CLLocationCoordinate2D coord = annotationView.annotation.coordinate;
        NSLog(@"Lat: %f, Lng: %f", coord.latitude, coord.longitude);
        
        MapPoint * newAnnotation = [[MapPoint alloc] initWithName:@"" address:@"" coordinate:coord];
        
        //[self.map removeAnnotations:self.map.annotations];
        [annotationView removeFromSuperview];
        //annotationView = nil;
        self.myPin = newAnnotation;
        [self.map addAnnotation:self.myPin];
        
    }
    
}



#pragma mark UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([alertView.title isEqual: @"GOT-JUNK"]){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


#pragma mark UITextField delegates

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - 175) animated:YES];
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // erase the default value in the amount field
    if (textField.tag == 1){
        if ([textField.text floatValue] == 0){
            textField.text = @"";
            
        }
        
    }
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y + 175) animated:YES];
    
    NSLog(@"Did begin editing");
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // if it's a return character, then always allow this
    if ([string isEqual: @"\n"] ) return YES;
    
    // define the maxlengths for different textfields
    int maxlength = 100;
    
    if (textField == self.tickettextField){
        maxlength = 30;
    } else if (textField == self.amounttextField){
        maxlength = 10;
    } else if (textField == self.descriptionTextField){
        maxlength = 100;
    }
    
    // check for string length
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > maxlength) ? NO : YES;
}

#pragma mark Expense recording callbacks


- (void)checkFinishExecutionState{
    
    // if either resource or expense is still executing, then don't do anything; just wait for both tasks to finish.
    if ((self.saveExpenseState == ExecutionStateExecuting) || (self.saveResourceCoordinatesState == ExecutionStateExecuting)) {
        return;
    }
    
    
    NSString * title;
    NSString * body;
    
    NSString *const successTitle = @"GOT-JUNK";
    NSString *const successBody = @"All details have been successfully saved.";
    
    NSString *const failedTitle = @"ERROR";
    NSString *const failedBody = @"There was a problem saving the data.  Please try again.";
    
    switch(self.saveExpenseState){
        case ExecutionStateSuccess:
            switch(self.saveResourceCoordinatesState){
                case ExecutionStateFailure:
                    title = @"There were some problems.";
                    body = @"Everything got updated, but we had problems saving the coordinates.  Weird, I know.  Please try saving again.";
                    break;
                default:  // Success/Off
                    title = successTitle;
                    body = successBody;
                    
                    break;
                
            }
            break;
        case ExecutionStateFailure:
            switch(self.saveResourceCoordinatesState){
                case ExecutionStateSuccess:
                    title = @"There were some problems.";
                    body = @"The coordinates of the chosen resource got updated, but the rest failed to get saved.  Weird, I know.  Please try saving again.";
                    break;
                default: // Failure/Off
                    title = failedTitle;
                    body = failedBody;
                    break;
            }
            break;
        default: // not saving expense, just resource (shouldn't be possible to hit this, since you always have to save expense)
            switch(self.saveResourceCoordinatesState){
                case ExecutionStateSuccess:
                    title = successTitle;
                    body = successBody;
                    
                    break;
                case ExecutionStateFailure:
                    title = failedTitle;
                    body = failedBody;
                    break;
                default: // Off
                    // shouldn't be able to get to this stage
                    title = @"Unknown error";
                    body = @"An unknown error has occurred";
                    break;
            }
            break;
    }
    
    UIAlertView * av = [[UIAlertView alloc]
                        initWithTitle:title
                        message:body
                        delegate:self
                        cancelButtonTitle:@"Close"
                        otherButtonTitles:nil];
    [av show];
    
    
    
}

- (void)createExpenseSuccessful
{
    self.myExpense = [DataStoreSingleton sharedInstance].currentExpense;

    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveExpenseState = ExecutionStateSuccess;
    [self checkFinishExecutionState];
    
}

- (void)createExpenseFailure
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveExpenseState = ExecutionStateFailure;
    [self checkFinishExecutionState];
}

- (void)updateExpenseSuccessful
{
    self.myExpense = [DataStoreSingleton sharedInstance].currentExpense;
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveExpenseState = ExecutionStateSuccess;
    [self checkFinishExecutionState];
    
    [Flurry logEvent:@"Create Expense"];
}

- (void)updateExpenseFailure
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveExpenseState = ExecutionStateFailure;
    [self checkFinishExecutionState];
}

- (void)updateResourceSuccessful
{
    self.myResource = [DataStoreSingleton sharedInstance].currentResource;

    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveResourceCoordinatesState = ExecutionStateSuccess;
    [self checkFinishExecutionState];
}

- (void)updateResourceFailure{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];

    self.saveResourceCoordinatesState = ExecutionStateFailure;
    [self checkFinishExecutionState];
}

@end
