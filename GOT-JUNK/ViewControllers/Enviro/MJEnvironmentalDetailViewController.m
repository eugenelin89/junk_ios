//
//  MJEnvironmentalDetailViewController.m
//  Example
//
//  Created by Mark Pettersson on 2013-07-25.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "DataStoreSingleton.h"
#import "Job.h"
#import "Lookup.h"
#import "UnitConversionHelper.h"

#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "JSONParserHelper.h"
#import "LookupTableViewController.h"
#import "ValidateHelper.h"
#import "UserDefaultsSingleton.h"
#import "FetchHelper.h"
#import "LoadTypeSize.h"
#import "Flurry.h"
#import "MJEnvironmentalDetailViewController.h"
#import "MJEnvironmentalJobDetailsCell.h"
#import "MJJobDetailViewController.h"
#import "MJDestinationsListViewController.h"
#import "MJJunkTypesListViewController.h"



@interface MJEnvironmentalDetailViewController ()

@property bool isWeightOverridden;
@property bool isDiversionOverridden;

@end


@implementation MJEnvironmentalDetailViewController

int _originalWeightTypeID; // weight type PRIOR to performing a change in selection for the weight type UISegmentedControl

static const int CUBIC_YARDS_PER_FULL_TRUCK = 15;
static const int POUNDS_PER_CUBIC_YARD = 156;
- (NSArray *)loadPointsArray
{
    if (!_loadPointsArray){
        _loadPointsArray = [[NSArray alloc] init];
    }
    return _loadPointsArray;
}
- (id)init
{
    self = [super init];
    
    // instantiate the enviro object in case we're trying to add a new
    // enviro record
    if (!self.enviro){
        self.enviro = [[Enviro alloc] init];
    }
    
    // need to still get loadTypeID
    self.loadPointsArray = [DataStoreSingleton sharedInstance].loadTypeSizeList;
        return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setInitialValues];
    [self setupMenuBarButtonItems];
    [self setupViews];
    [self setupNotificationObservers];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}




-(void)dismissKeyboard
{
    [self.diversionTextField resignFirstResponder];
    [self.weightTextField resignFirstResponder];
}
- (void)setupViews
{
    [self.view endEditing:YES];
    self.scrollView.frame = CGRectMake(0,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,self.scrollView.frame.size.height);
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView endEditing:YES];
    
    self.subView.frame = CGRectMake(0,0,self.subView.frame.size.width, self.subView.frame.size.height);
    [self.scrollView addSubview:self.subView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [DataStoreSingleton sharedInstance].currentLookup = nil;
    [DataStoreSingleton sharedInstance].currentLookupMode = nil;
    self.enviroDestination = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if we had just transitioned back from a picker screen, then
    // see what item was selected then put it into the appropriate label
    // on the current screen
    NSString * lookupMode = [DataStoreSingleton sharedInstance].currentLookupMode;
    
    if ([lookupMode isEqualToString:@"ENVIRONMENTJUNKTYPE"])
    {
        self.enviro.junkTypeID = self.junkType.itemID;
        self.junkTypeLabel.text = self.junkType.itemName;
        // recalculate the weight of the junk ... but only if weight hasn't already been overridden
        
        if (!self.isWeightOverridden)
            self.weightTextField.text = [NSString stringWithFormat:@"%.2f", [self calculateWeight]];
        
    }
    else if ([lookupMode isEqualToString:@"ENVIRONMENTALDESTINATIONS"])
    {
        self.enviro.destinationID = self.enviroDestination.itemID;
        self.accountLabel.text = self.enviroDestination.itemName;
        self.enviro.defaultDiversion = self.enviroDestination.diversionPercent;
        
        // update the diversion percentage control, but only if diversion hasn't been overridden yet
        
        if (!self.isDiversionOverridden)
        {
            self.diversionTextField.text = [NSString stringWithFormat:@"%.0f", self.enviroDestination.diversionPercent];
            self.diversionTextField.userInteractionEnabled = self.enviroDestination.isSortable;
        }
    }
}



- (void)setupNotificationObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEnviroSuccessful)
                                                 name:@"SendUpdateEnvironmentalSuccessful" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEnviroFailed)
                                                 name:@"SendUpdateEnvironmentalFailure" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}


- (void)keyboardWasShown:(NSNotification *)notification
{

    UITextField * textField; // whatever textfield is first responder
    
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // find first responder
    for (UIView * view in self.subView.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]){
            textField = (UITextField *)view;
            break;
        }
    }
    
    CGRect bkgndRect = textField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [textField.superview setFrame:bkgndRect];
    [self.scrollView setContentOffset:CGPointMake(0.0, textField.frame.origin.y - kbSize.height) animated:YES];

}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    
}

- (void)updateEnviroSuccessful
{
    [Flurry logEvent:@"Create Enviro"];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Hoorah!"
                       message:@"The environmental information was successfully recorded in JunkNet."
                       delegate:self
                       cancelButtonTitle:@"Close"
                       otherButtonTitles: nil];
    [av show];
}

- (void)updateEnviroFailed
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Environmental update failed!"
                       message:@"The environmental information could not be recorded. Please try again."
                       delegate:self
                       cancelButtonTitle:@"Close"
                       otherButtonTitles: nil];
    [av show];
}


- (int)getLoadTypeID
{
    return ([self.pickerView selectedRowInComponent:0] + 1);
}

- (NSString *)getLoadType:(int)loadTypeID
{
    switch(loadTypeID){
        case 1:
            return @"Volume";
        default:
            return @"Bedload";
    }
}


- (int)getWeightTypeID
{
    return self.weightTypeSegment.selectedSegmentIndex + 1;
}

- (NSString *)getLoadTypeSize:(int)loadTypeSizeID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadTypeSizeID = %d", loadTypeSizeID];
    
    NSArray *results = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
    if (results && results.count > 0)
    {
        return ((LoadTypeSize *)([results objectAtIndex:0])).loadTypeSize;
    } else
    {
        return @"";
    }
}

- (int)getLoadTypeSizeID
{
    int loadTypeID = [self getLoadTypeID];
    // get the correct loadTypeSizeID
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"loadTypeID = %d", loadTypeID];
    NSArray * filteredLoadSizesArray = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
    return ((LoadTypeSize *)([filteredLoadSizesArray objectAtIndex:[self.pickerView selectedRowInComponent:2]])).loadTypeSizeID;
}

- (float)getLoadTypeSizePercentOfTruck:(int)loadTypeSizeID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadTypeSizeID = %d", loadTypeSizeID];
    NSArray *results = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
    if (results && results.count > 0)
    {
        return ((LoadTypeSize *)([results objectAtIndex:0])).percentOfTruck;
    } else
    {
        return 0;
    }
}

// piece together an Enviro object based on the user input
- (Enviro *)getPostedEnviroData
{
    int loadTypeID = [self getLoadTypeID];
    int loadTypeSizeID = [self getLoadTypeSizeID];
    // create an Enviro object holding just the inputs from the current enviro
    
    Enviro * enviro = [[Enviro alloc] init];
    enviro.environmentID = self.enviro.environmentID;
    enviro.environmentCategorizationID = self.enviro.environmentCategorizationID;
    enviro.loadTypeID = loadTypeID;
    enviro.loadType = [self getLoadType:loadTypeID];
    enviro.numberOfTrucks = [self.pickerView selectedRowInComponent:1];
    enviro.loadTypeSizeID = loadTypeSizeID;
    enviro.loadTypeSize = [self getLoadTypeSize:loadTypeSizeID];
    enviro.junkTypeID = self.enviro.junkTypeID;
    enviro.junkType = self.junkTypeLabel.text;
    enviro.destinationID = self.enviro.destinationID;
    enviro.destination = self.accountLabel.text;
    enviro.percentOfJob = 0; // will be calculated in this function
    float userDiversion = [self.diversionTextField.text floatValue];
    enviro.defaultDiversion = self.enviro.defaultDiversion;
    // check if the user diversion has been overridden
    if (userDiversion != enviro.defaultDiversion)
        enviro.userDiversion = userDiversion;
    else {
        // this indicates that diversion was never overridden
        enviro.userDiversion = -1;
    }
    
    enviro.weightTypeID = (self.weightTypeSegment.selectedSegmentIndex + 1);
    enviro.weightType = [self.weightTypeSegment titleForSegmentAtIndex:(enviro.weightTypeID - 1)];
    
    enviro.actualWeight = [UnitConversionHelper convertWeight:[self.weightTextField.text floatValue] fromType:enviro.weightTypeID toType:1];
    enviro.calculatedWeight = [self calculateWeight];
    enviro.calculatedLoadSize = [self getLoadTypeSizePercentOfTruck:enviro.loadTypeSizeID];
    enviro.jobID = [self.job.jobID intValue];
    // if weight was never overridden, set value to 0 to indicate as such
    if (roundf(enviro.calculatedWeight) == roundf(enviro.actualWeight))
    {
        enviro.actualWeight = -1;
    }
    
    return enviro;
}

- (void)setInitialValues
{
    if (self.enviro.environmentCategorizationID > 0)
    {
        // set the picker view with the appropriate values
        
        // set load type
        [self.pickerView selectRow:(self.enviro.loadTypeID - 1) inComponent:0 animated:YES];
        
        // set the truck wholes
        [self.pickerView selectRow:(self.enviro.numberOfTrucks) inComponent:1 animated:YES];
        
        // set the truck fractions
        int index = 0;
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadTypeID == %d", self.enviro.loadTypeID];
        NSArray * resultsArray = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
        if (resultsArray && (resultsArray.count > 0)) {
            for (int i =0; i< resultsArray.count; i++) {
                LoadTypeSize * size = (LoadTypeSize *)([resultsArray objectAtIndex:i]);
                if (size.loadTypeSizeID == self.enviro.loadTypeSizeID)
                {
                    index = i;
                    break;
                }
            }
        }
        [self.pickerView selectRow:index inComponent:2 animated:YES];
        // set junk type and destination
        self.junkTypeLabel.text = self.enviro.junkType;
        
        self.accountLabel.text = self.enviro.destination;
        
        // set initial values for diverted %
        // use default diversion if user diversion is undefined
        
        if (self.enviro.userDiversion >= 0){
            self.diversionTextField.text = [NSString stringWithFormat:@"%.0f", self.enviro.userDiversion];
        }
        else {
            self.diversionTextField.text = [NSString stringWithFormat:@"%.0f", self.enviro.defaultDiversion];
        }
        
        
        // starting from self.enviro.weight (a value in pounds),
        // convert to user's chosen unit of measurement
        
        float weight = self.enviro.actualWeight;
        if (weight < 0){
            weight = self.enviro.calculatedWeight;
        }
        float convertedWeight = [UnitConversionHelper convertWeight:weight fromType:1 toType:self.enviro.weightTypeID];
        
        
        // if actual weight is defined, this means calculated weight was overridden
        if (self.enviro.actualWeight >= 0)
            self.isWeightOverridden = YES;
        else
            self.isWeightOverridden = NO;
        
        // if user diversion is defined, that means default diversion was overridden
        if (self.enviro.userDiversion >= 0)
            self.isDiversionOverridden = YES;
        else
            self.isDiversionOverridden = NO;
        self.weightTextField.text = [NSString stringWithFormat:@"%.2f", convertedWeight];
        self.weightTypeSegment.selectedSegmentIndex = (self.enviro.weightTypeID - 1);
        _originalWeightTypeID = self.enviro.weightTypeID;
        
        
        
    }
    else
    {
        // set to pounds by default
        self.weightTypeSegment.selectedSegmentIndex = 0;
        _originalWeightTypeID = 1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Calculation Methods


// formula for computing weight - multiple all these together:
// percentOfJob/100  (i.e. percentage of overall job that the current breakdown includes)
// jobSize (of current breakdown)
// cubicYards (of one truckload of chosen load type)
// poundsPerCubicYard
- (float)calculateWeight {
    
    // return 0 if ...
    //      - no trucks/fractions have been selected
    //      - no junk type has been selected
    
    if (
        (([self.pickerView selectedRowInComponent:1] == 0) && ([self.pickerView selectedRowInComponent:2] == 0)) ||
        (self.enviro.junkTypeID == 0)
        )
    {
        return 0;
    }
    
    //Enviro * enviro = [self getPostedEnviroData];
    Enviro * enviro = [[Enviro alloc] init];
    enviro.loadTypeID = [self getLoadTypeID];
    enviro.loadTypeSizeID = [self getLoadTypeSizeID];
    enviro.numberOfTrucks = [self.pickerView selectedRowInComponent:1];
    enviro.weightTypeID = (self.weightTypeSegment.selectedSegmentIndex + 1);
    
    // calculate percent of job.
    //float percentOfJob = [self calculatePercentOfJob:enviro];
    
    // need to compute total weight of truck
    float jobSize = [self calculateTotalTruckloads:enviro];
    
    
    //float jobSize = [self calculateJobSize:enviro.loadTypeID includingEnviro:enviro];
    
    float cubicYards = CUBIC_YARDS_PER_FULL_TRUCK;
    float weightPerCubicYards = POUNDS_PER_CUBIC_YARD;  //self.junkType.poundsPerCubicYard;
    //float weightInPounds = (percentOfJob / 100) * jobSize * cubicYards * weightPerCubicYards;
    float weightInPounds = jobSize * cubicYards * weightPerCubicYards;
    
    return weightInPounds;
    
    //return [UnitConversionHelper convertWeight:weightInPounds fromType:1 toType:enviro.weightTypeID];
}

// calculate the total size of all the enviro breakdowns with the matching load type
- (float)calculateJobSize:(int)loadTypeID {
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"loadTypeID = %d", loadTypeID];
    
    NSArray * enviroArray = [[DataStoreSingleton sharedInstance].enviroDict objectForKey:self.job.jobID];
    NSArray * filteredEnviroArray = [enviroArray filteredArrayUsingPredicate:predicate];
    
    float totalJobSize = 0;
    for (Enviro * e in filteredEnviroArray){
        totalJobSize += [self calculateTotalTruckloads:e];
    }
    return totalJobSize;
}

- (float)calculateJobSize:(int)loadTypeID includingEnviro:(Enviro *)enviro
{
    float totalJobSize = [self calculateJobSize:loadTypeID];
    
    if (enviro.loadTypeID == loadTypeID)
        totalJobSize += [self calculateTotalTruckloads:enviro];
    
    return totalJobSize;
}

- (float)calculatePercentOfJob:(Enviro *)enviro {
    
    NSMutableArray * enviroArray = (NSMutableArray *)([[DataStoreSingleton sharedInstance].enviroDict objectForKey:self.job.jobID]);
    
    
    // get just those breakdowns that belong to the same load type, but leave
    // off the current breakdown
    
    int loadTypeID = [self getLoadTypeID];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"(loadTypeID == %d) AND (environmentCategorizationID != %d)", loadTypeID, self.enviro.environmentCategorizationID];
    
    NSMutableArray * matchingEnviroArray = [[NSMutableArray alloc] initWithArray:[enviroArray filteredArrayUsingPredicate:predicate]];
    
    [matchingEnviroArray addObject:enviro];
    
    
    // take sum of all truckloads occupied by all enviro breakdowns
    
    // then for each breakown, take its total truck size and
    // divide it by the sum in order to compute its percentage of the entire job
    
    float allEnviroTruckloads = 0;
    for (Enviro * e in matchingEnviroArray)
    {
        e.totalTruckSize = [self calculateTotalTruckloads:e];
        allEnviroTruckloads += e.totalTruckSize;
    }
    
    // need to avoid divide-by-zero error.
    // we would only ever be in this situation if the current breakdown is the ONLY breakdown, and
    // user has chosen 0 truckloads and the "0" fraction.
    if (allEnviroTruckloads == 0) {
        return 100;
    }
    else {
        
        return roundf((enviro.totalTruckSize / allEnviroTruckloads) * 100);
    }
    
}

- (float)calculateTotalTruckloads:(Enviro *)enviro
{
    // get the percentage occupancy of the fraction
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"loadTypeSizeID = %d", enviro.loadTypeSizeID];
    NSArray * results = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
    float percentOfTruck = 0;
    if (results && results.count > 0) {
        percentOfTruck = ((LoadTypeSize *)([results objectAtIndex:0])).percentOfTruck;
    }
    
    return percentOfTruck + enviro.numberOfTrucks;
}


#pragma mark Add/Update Enviro

- (void)saveEnviro
{
    if (![self doValidate]){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    Enviro * enviro = [self getPostedEnviroData];
    
    enviro.calculatedWeight = [self calculateWeight];
    enviro.totalTruckSize = [self calculateTotalTruckloads:enviro];
    
    // put together an array of Enviro objects
    // this will include all the other Enviro objects from the enviroDict,
    // minus this one.
    
    // let's grab all the enviro breakdowns for this job
    
    NSMutableArray * enviroArray = ((NSMutableArray *)([[DataStoreSingleton sharedInstance].enviroDict objectForKey:self.job.jobID]));
    
    
    
    NSMutableArray * enviroArrayCopy = [NSMutableArray arrayWithArray:enviroArray];
    
    if (enviro.environmentCategorizationID > 0) {
        
        // if we're doing an update, then get rid of the enviro object in the array.
        
        for (Enviro *thisEnviro in enviroArrayCopy){
            if (enviro.environmentCategorizationID == thisEnviro.environmentCategorizationID){
                [enviroArrayCopy removeObject:thisEnviro];
                break;
            }
        }
    }
    
    [enviroArrayCopy addObject:enviro];
    
    // compute total truckloads for each breakdown
    for (Enviro * thisEnviro in enviroArrayCopy){
        thisEnviro.totalTruckSize = [self calculateTotalTruckloads:thisEnviro];
    }
    
    [[FetchHelper sharedInstance] saveEnviro:enviroArrayCopy isDeletion:NO forJobID:[self.job.jobID intValue]];
}

#pragma mark UI setup

- (void)setupMenuBarButtonItems {
    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    self.navigationItem.backBarButtonItem = [self backMenuBarButtonItem];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(saveEnviro)];
}

- (UIBarButtonItem *)backMenuBarButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark Validation 

/*
 * Rules to validate:
 *  - must have a selected load size
 *  - must choose a junk type
 *  - must choose destination
 *  - must have an inputted diversion that is positive numeric
 *  - must have an inputted weight that is positive numeric
 *
 */
- (bool)doValidate
{
    // check if either a non-zero truckload or truckload fraction has been selected
    NSString *errorMessage = [[NSString alloc] init];
    
    if ([self.pickerView selectedRowInComponent:1] == 0 && [self.pickerView selectedRowInComponent:2] == 0){
        errorMessage = @"You need to select a load size.";
    }
    else if (!self.enviro.junkTypeID || self.enviro.junkTypeID == 0){
        errorMessage = @"You must select a junk type.";
    }
    else if (!self.enviro.destinationID || self.enviro.destinationID == 0){
        errorMessage = @"You must select a destination.";
    }
    else if (!(
               ([ValidateHelper valNumeric:self.diversionTextField.text]) &&
               ([self.diversionTextField.text floatValue] >= 0) &&
               ([self.diversionTextField.text floatValue] <= 100)
               )){
        errorMessage = @"You must enter a diversion value between 0 and 100 inclusive.";
    }
    else if (![ValidateHelper valNumeric:self.weightTextField.text] || [self.weightTextField.text floatValue] <= 0){
        errorMessage = @"You must enter a positive numeric weight.";
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


#pragma mark Event Handlers



- (IBAction) weightInputFinished:(UITextField *)sender
{
    // if the user entered garbage, don't do anything
    if (![ValidateHelper valNumeric:sender.text])
    {
        self.isWeightOverridden = YES;
        [sender resignFirstResponder];
        return;
    }
    
    NSString * weightText = sender.text;
    float actualWeight = [sender.text floatValue];
    
    // if user has erased the textfield contents or set value to 0,
    // then reset the value to the calculated weight.
    
    if ((weightText.length == 0) || (actualWeight == 0)){
        sender.text = [NSString stringWithFormat:@"%.2f", self.enviro.calculatedWeight];
        self.isWeightOverridden = NO;
        
    } else {
        
        // convert to pounds
        int weightTypeID = [self getWeightTypeID];
        
        // if weight is not in pounds already, then convert to pounds
        if (weightTypeID != 1) {
            actualWeight = [UnitConversionHelper convertWeight:actualWeight fromType:weightTypeID toType:1];
        }
        
        // if the weight has changed, then raise flag that weight's been overridden
        if (roundf(actualWeight) != roundf(self.enviro.calculatedWeight)){
            self.isWeightOverridden = YES;
        } else {
            self.isWeightOverridden = NO;
        }
    }
        
    [sender resignFirstResponder];
}


- (IBAction) diversionInputFinished:(UITextField *)sender
{
    NSString * defaultDiversionString = [NSString stringWithFormat:@"%.0f", self.enviro.defaultDiversion];
    
    // check if value of the text has changed
    
    if (self.diversionTextField.text.length == 0) {
        self.diversionTextField.text = defaultDiversionString;
        self.isDiversionOverridden = NO;
        
    }
    else if ([self.diversionTextField.text isEqualToString:defaultDiversionString]){
        self.isDiversionOverridden = NO;
        
    } else {
        self.isDiversionOverridden = YES;
        
    }
    
    
    [sender resignFirstResponder];
}


- (IBAction) chooseJunkType:(UIButton *)sender
{
    MJJunkTypesListViewController *vc = [[MJJunkTypesListViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction) chooseAccount:(UIButton *)sender
{
    MJDestinationsListViewController * vc = [[MJDestinationsListViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];

}


- (IBAction) changeWeightType:(UISegmentedControl *)sender
{
    // take current value of weightType.text and convert it to the new weight type
    
    int newWeightTypeID = (sender.selectedSegmentIndex + 1);
    
    float convertedWeight = [UnitConversionHelper convertWeight:[self.weightTextField.text floatValue] fromType:_originalWeightTypeID toType:newWeightTypeID];
    
    self.weightTextField.text = [NSString stringWithFormat:@"%f", convertedWeight];
    
    _originalWeightTypeID = newWeightTypeID;
}



#pragma mark UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([alertView.title isEqual: @"Hoorah!"]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Picker view data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // column 1: volume/bedload
    // column 2: # full truckloads
    // column 3: truckload fractions
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch(component)
    {
        case 0: // volume/bedload
            return 2;
        case 1: // 0 ... 10 (truckloads)
            return 11;
        default: {// 1/4, 2/4, 3/4
            
            // if it's a new breakdown, then assume it's volume
            if (self.enviro.loadTypeID < 2) return 13;
            else return 4;
            
            
        }
    }
}

#pragma mark - Picker view delegates



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(component)
    {
        case 0:
            switch(row)
            {
                case 0: return @"Volume";
                default: return @"Bedload";
            }
            
        case 1:
            return [NSString stringWithFormat:@"%d", row];
            
            
        default: {
            // do a search in the loadPointsArray array, and look for the load sizes corresponding to the chosen load type (volume or bedload)
            
            int loadTypeID = self.enviro.loadTypeID;
            
            if (loadTypeID == 0){
                loadTypeID = 1;
            }
           // loadTypeID = 0; // added for testing by mark temporarily
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"loadTypeID = %d", loadTypeID];
            NSArray * filteredLoadSizesArray = [self.loadPointsArray filteredArrayUsingPredicate:predicate];
            
            if (!filteredLoadSizesArray || filteredLoadSizesArray.count == 0)
                return @"";
            else
                return ((LoadTypeSize *)[filteredLoadSizesArray objectAtIndex:row]).loadTypeSize;
            break;
        }
    };
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // record the selected values
    
    if (component == 0){
        self.enviro.loadTypeID = (row+1);
        
        // reload the fractions
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    
    // calculate weight, but only if weight hasn't already been overridden
    
    if (!self.isWeightOverridden){
        float weight = [UnitConversionHelper convertWeight:[self calculateWeight] fromType:1 toType:[self getWeightTypeID]];
        
        self.weightTextField.text = [NSString stringWithFormat:@"%.2f", weight];
        
        
    }
    
    
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the job attached to current enviro record
    
    static NSString *CellIdentifier = @"MJEnvironmentalJobDetailsCell";
    
    MJEnvironmentalJobDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MJEnvironmentalJobDetailsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    // set job type icon
    UIImage * image = [[UIImage alloc] init];

    switch ([self.job.clientTypeID integerValue]) {
        case 1:
        {
            cell.jobTypeLabel.text = @"Res";
            if ([self.job.junkCharge integerValue]> 0)
            {
                image = [UIImage imageNamed: @"houseGreenChecked.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"houseGreen.png"];
            }
            
        }
            break;
        case 2:
        {
            cell.jobTypeLabel.text = @"Comm";
            if ([self.job.junkCharge integerValue]> 0)
            {
                image = [UIImage imageNamed: @"commercialGreenChecked.png"];
            }
            else
            {
                image = [UIImage imageNamed: @"commercialGreen.png"];
            }
            
        }
            break;
        default:
            break;
    }
    if ([self.job.jobType integerValue] == 2)
    {
        image = [UIImage imageNamed: @"pencilGreen.png"];
    }
    
    
    

    [cell.jobTypeIcon setImage:image];
    cell.pickupZipLabel.text = self.job.zipCode;
    cell.clientNameLabel.text = self.job.clientName;
    cell.clientCompanyLabel.text = self.job.clientCompany;
    cell.jobIDLabel.text = [NSString stringWithFormat:@"%@", self.job.jobID];
    if (!self.job.isEnviroRequired) {
        [cell.enviroRequiredLabel setHidden:YES];
        [cell.enviroRequiredIcon setHidden:YES];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


- (UIView*) tableView: (UITableView*) tableView
viewForHeaderInSection: (NSInteger) section
{
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // punt the user over to the job details screen
    MJJobDetailViewController * vc = [[MJJobDetailViewController alloc] init];
    vc.currentJob = self.job;
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


@end
