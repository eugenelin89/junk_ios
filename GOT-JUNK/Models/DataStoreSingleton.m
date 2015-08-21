//
//  DataStoreSingleton.m
//  GOT-JUNK
//
//  Created by epau on 1/31/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "DataStoreSingleton.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Job.h"
#import "Expense.h"
#import "Route.h"
#import "Enviro.h"
#import "APIObjectConversionHelper.h"
#import "DateHelper.h"
#import "MapPoint.h"
#import "CoreDataStore/CDJob+GotJunk.h"
#import "CoreDataStore/CDRoute+GotJunk.h"
#import "UserDefaultsSingleton.h"
#import "CoreDataStore/CDUser+GotJunk.h"
#import "Mode.h"
#import "ActiveMode.h"

@interface DataStoreSingleton()
@property (nonatomic, strong) id<Mode> mode;

@end

@implementation DataStoreSingleton
{
    int currentNotificationPageNumber;
    UIManagedDocument * _document;
}

@synthesize currentLookupMode = _currentLookupMode;
@synthesize lookupList = _lookupList;
@synthesize jobList = _jobList;
@synthesize routeList = _routeList;
@synthesize taxList = _taxList;
@synthesize paymentMethodList = paymentMethodList;
@synthesize currentRoute = _currentRoute;
@synthesize currentDate = _currentDate;
@synthesize expenseAccountsList = _expenseAccountsList;
@synthesize expensesDict = _expensesDict;
@synthesize currentPaymentMethod = _currentPaymentMethod;
@synthesize currentLookup = _currentLookup;
@synthesize permissions = _permissions;
@synthesize currentJobPaymentID = _currentJobPaymentID;
@synthesize pushJob = _pushJob;
@synthesize routeJobs = _routeJobs;
@synthesize isConnected = _isConnected;
@synthesize isUserLoggedIn = _isUserLoggedIn;
@synthesize debugDisplayText1 = _debugDisplayText1;
@synthesize debugDisplayText2 = _debugDisplayText2;
@synthesize notificationList = _notificationList;
@synthesize currentJob = _currentJob;
@synthesize filterRoute = _filterRoute;
@synthesize assignedRoutes = _assignedRoutes;
@synthesize mode = _mode;

+ (DataStoreSingleton *)sharedInstance
{
    static DataStoreSingleton *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sharedInstance = [[DataStoreSingleton alloc] init];
        _sharedInstance.mode = [[ActiveMode alloc] init]; // initialize as Active Mode.
        _sharedInstance.isConnected = YES;
        _sharedInstance.isUserLoggedIn = YES;
        _sharedInstance->currentNotificationPageNumber = 0;
        
        [_sharedInstance prepareCoreDataStore];
        
        
        

    });

    return _sharedInstance;
}

-(void)prepareCoreDataStore
{
    self.managedObjectContext = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDir = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [documentDir URLByAppendingPathComponent:@"junkstore.md"];
    _document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[url path]]){
        [_document openWithCompletionHandler:^(BOOL success) {
            [self documentIsReady];
        }];
    }else{
        [_document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              [self documentIsReady];
        }];
    }
}

-(void)documentIsReady
{
    if(_document.documentState ==  UIDocumentStateNormal){
        self.managedObjectContext = _document.managedObjectContext;
        [[NSNotificationCenter defaultCenter] postNotificationName:COREDATAREADY_NOTIFICATION object:nil];
        NSLog(@"\n\n *** CORE DATA READY! ***\n\n");
    }
}



- (NSMutableArray *)mapPointsList
{
    if (!_mapPointsList){
        _mapPointsList = [[NSMutableArray alloc] init];
    }
    return _mapPointsList;
}
- (NSMutableArray *)jobsPointsList
{
    if (!_jobsPointsList){
        _jobsPointsList = [[NSMutableArray alloc] init];
    }
    return _jobsPointsList;
}

- (NSMutableArray *)gasPointsList
{
    if (!_gasPointsList){
        _gasPointsList = [[NSMutableArray alloc] init];
    }
    return _gasPointsList;
}
- (NSMutableArray *)depotsPointsList
{
    if (!_depotsPointsList){
        _depotsPointsList = [[NSMutableArray alloc] init];
    }
    return _depotsPointsList;
}

- (NSMutableArray *)enviroDestinationsList
{
    if (!_enviroDestinationsList){
        _enviroDestinationsList = [[NSMutableArray alloc] init];
    }
    return _enviroDestinationsList;
}
- (NSNumber *)currentJobPaymentID
{
    if (!_currentJobPaymentID){
        _currentJobPaymentID = [[NSNumber alloc] init];
    }
    return _currentJobPaymentID;
}

- (NSMutableArray *)paymentList
{
    if (!_paymentList){
        _paymentList = [[NSMutableArray alloc] init];
    }
    return _paymentList;
}

- (NSMutableArray *)dispatchesList
{
    if (!_dispatchesList){
        _dispatchesList = [[NSMutableArray alloc] init];
    }
    return _dispatchesList;
}

- (NSMutableArray *)lookupList
{
    if (!_lookupList){
        _lookupList = [[NSMutableArray alloc] init];
    }
    return _lookupList;
}

- (void)setResourcesList:(NSMutableArray *)list
{
    _resourcesList = list;
    
    [self setResourcesLocations];
}

- (NSString *)permissions
{
    if (!_permissions){
        _permissions = [[NSString alloc] init];
    }
    return _permissions;
}
- (NSArray *)assignedRoutes
{
    if (!_assignedRoutes){
        _assignedRoutes = [[NSArray alloc] init];
    }
    return _assignedRoutes;
}

/*
-(void) setAssignedRoutes:(NSArray *)assignedRoutes
{
    _assignedRoutes = assignedRoutes;
    
    [CDUser assignRoutes:assignedRoutes toUserWithID:[[UserDefaultsSingleton sharedInstance] getUserID] inManagedObjectContext:self.managedObjectContext];
    
    
    
}
*/

- (NSDictionary *)expensesDict;
{
    if (!_expensesDict) {
        _expensesDict = [[NSDictionary alloc] init];
    }
    return _expensesDict;
}

- (NSMutableDictionary *)routeJobs;
{
    if (!_routeJobs && self.managedObjectContext) {
        _routeJobs = [[NSMutableDictionary alloc] init];
        
    }
    return _routeJobs;
}

-(void) setRouteJobs:(NSMutableDictionary *)routeJobs
{
    _routeJobs = routeJobs;
}

- (Job *)pushJob;
{
    if (!_pushJob) {
        _pushJob = [[Job alloc] init];
    }
    return _pushJob;
}

- (Lookup *)currentLookup
{
    if (!_currentLookup){
        _currentLookup = [[Lookup alloc] init];
    }
    return _currentLookup;
}

- (PaymentMethod *)currentPaymentMethod
{
    if (!_currentPaymentMethod){
        _currentPaymentMethod = [[PaymentMethod alloc] init];
    }
    return _currentPaymentMethod;
}

- (Expense *)currentExpense;
{
    if (!_currentExpense) {
        _currentExpense = [[Expense alloc] init];
    }
    return _currentExpense;
}

- (Resource *)currentResource;
{
    if (!_currentResource) {
        _currentResource = [[Resource alloc] init];
    }
    return _currentResource;
}


- (NSMutableArray *)notificationList
{
    if (!_notificationList){
        _notificationList = [[NSMutableArray alloc] init];
    }
    return _notificationList;
}

-(NSArray *)jobList
{
    if(self.managedObjectContext){
        _jobList = [CDJob jobsForDate:self.currentDate forRoute:[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] InManagedContext:self.managedObjectContext];
    }
    return _jobList;
}


- (void)setJobList:(NSArray *)jobList
{
    _jobList = jobList;
    
    [self setJobLocations];
    
    // store in core data
    [CDJob loadJobsFromArray:jobList inManagedObjectContext:self.managedObjectContext];
    
}

-(NSArray *)routeList
{
    NSArray *result;
    if(!_routeList && self.managedObjectContext){
        result = [CDRoute routesInManagedObjectContext:self.managedObjectContext];
    }else{
        result = _routeList;
    }
    return result;
}

-(void)setRouteList:(NSArray *)routeList
{
    _routeList = routeList;
    [CDRoute loadRoutesFromArray:routeList inManagedObjectContext:self.managedObjectContext];
    
}

- (void)setCurrentJobPaymentID:(NSNumber *)jobID
{
    _currentJobPaymentID = jobID;
}

-(void)addExpense:(Expense *)expense expenseTypeID:(int)et
{
    [[self.expensesDict objectForKey:[[NSNumber alloc] initWithInt:et]] addObject:expense];
}

- (Job*)currentJob
{
    if(!_currentJob)
    {
        _currentJob = [[Job alloc] init];
    }
    return _currentJob;
}

- (Route*)filterRoute
{
    if(!_filterRoute)
    {
        _filterRoute = [[Route alloc] init];
    }
    return _filterRoute;
}

-(void) setIsUserLoggedIn:(BOOL)isUserLoggedIn
{
    _isUserLoggedIn = isUserLoggedIn;
    if(isUserLoggedIn){
        self.mode = [self.mode loggedIn];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGGEDIN_NOTIFICATION object:nil];
    }else{
        self.mode = [self.mode loggedOut];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGGEDOUT_NOTIFICATION object:nil];
    }
}

-(void) setIsConnected:(BOOL)isConnected
{
    _isConnected = isConnected;
    if(isConnected){
        self.mode = [self.mode reconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECONNECTED_NOTIFICATION object:nil];
    }else{
        self.mode = [self.mode disconnect];
        [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECTED_NOTIFICATION object:nil];
    }
}

-(NSDate*) jobsLastUpdateTime
{
    NSDate *time = [[UserDefaultsSingleton sharedInstance] jobsLastUpdateAt];
    return time;
}

-(void) setJobsLastUpdateTime:(NSDate *)jobsLastUpdateTime
{
    [[UserDefaultsSingleton sharedInstance] setJobsLastUpdateTime:jobsLastUpdateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:JOBSTIMESTAMPUPDATE_NOTIFICATION object:nil];
}


- (void)mergeJobs:(NSArray *)jobs
{
    NSMutableArray *tempJobList = [NSMutableArray array];

    for (Job* newJob in jobs)
    {
        BOOL added = NO;

        for (Job* oldJob in self.jobList)
        {
            if ([oldJob.jobID isEqual: newJob.jobID])
            {
                // If a job with the same JobID is already present, then update the values of the existing Job.
                [Job updateValuesOfJob: oldJob withNewJob: newJob];
                [tempJobList addObject: oldJob];
                added = YES;
            }
        }

        if (!added)
        {
            // If the job is NOT present, add it to the jobList
            [tempJobList addObject: newJob];
        }
    }
    
    self.jobList = [NSArray arrayWithArray: tempJobList];
}

-(void)deleteAllData
{
    self.dispatchesList = nil;
    self.lookupList = nil;
    self.jobList = nil;
    self.routeList = nil;
    self.taxList=nil;
    self.paymentMethodList = nil;
    self.franchiseList = nil;
    self.assignedRoutes = nil;
    self.enviroDestinationsList = nil;
    self.junkTypesList = nil;
    self.paymentList = nil;
    self.expensesDict = nil;
    self.expenseAccountsList = nil;
    self.enviroDict = nil;
    self.permissions = nil;
    self.currentLookupMode = nil;
    self.currentLookup = nil;
    self.currentExpense = nil;
    self.currentPaymentMethod = nil;
    self.currentRoute = nil;
    self.loadTypeSizeList = nil;
    self.pushJob = nil;
    self.routeJobs = nil;
}

-(void)removeJobsInLocalPersistentStoreForDate:(NSDate*) date forRoute:(NSNumber*)routeID
{
    [CDJob deleteJobsForDate:date forRoute:routeID inManagedContext:self.managedObjectContext];
}

-(void)removeJobsInLocalPersistentStoreForDate:(NSDate*)fromDate toDate:(NSDate*)toDate forRoute:(NSNumber*)routeID
{
    [CDJob deleteJobsForDate:fromDate toDate:toDate forRoute:routeID inManagedContext:self.managedObjectContext];
}


- (NSInteger)pendingDispatches
{
  return [UIApplication sharedApplication].applicationIconBadgeNumber;
}

- (void)setPendingDispatches:(NSInteger)badgeCount
{
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)decrementPendingDispatches
{
//  NSInteger currentBadgeNumber = [self pendingDispatches];
//  if (currentBadgeNumber > 0) {
//    NSInteger newBadgeNumber = currentBadgeNumber - 1;
// //   [self setPendingDispatches: newBadgeNumber - 1];
//  } else {
//    // fugheddaboudit
//  }
}

- (void)getJobListForCachedCurrentRoute
{
    self.jobList = [self.routeJobs objectForKey:self.currentRoute.routeID];
}

- (void)clearRouteJobs
{
    [self.routeJobs removeAllObjects];
}

- (void)addJobsList:(NSArray*)jobListArray forRoute:(NSNumber*)routeID;
{
    [self.routeJobs setObject:jobListArray forKey:routeID];
    [CDRoute addJobs:jobListArray toRouteWithID:routeID inManagedObjectContext:self.managedObjectContext];
}

- (Enviro *)mapEnviro:(NSDictionary *)dict
{
    Enviro *enviro = [[Enviro alloc] init];
    
    enviro.environmentID = [[dict objectForKey:@"environmentID"] integerValue];
    enviro.environmentCategorizationID =[[dict objectForKey:@"environmentCategorizationID"] integerValue];
    enviro.loadType = [dict objectForKey:@"loadType"];
    enviro.loadTypeID = [[dict objectForKey:@"loadTypeID"] integerValue];
    enviro.numberOfTrucks = [[dict objectForKey:@"numberOfTrucks"] integerValue];
    enviro.loadTypeSize = [dict objectForKey:@"loadTypeSize"];
    enviro.loadTypeSizeID = [[dict objectForKey:@"loadTypeSizeID"] integerValue];
    enviro.junkTypeID = [[dict objectForKey:@"junkTypeID"] integerValue];
    enviro.junkType = [dict objectForKey:@"junkType"];
    enviro.destinationID = [[dict objectForKey:@"destinationID"] integerValue];
    enviro.destination = [dict objectForKey:@"destination"];
    enviro.percentOfJob = [[dict objectForKey:@"percentOfJob"] integerValue];
    enviro.weightTypeID = [[dict objectForKey:@"weightTypeID"] integerValue];
    enviro.weightType = [dict objectForKey:@"weightType"];
    enviro.calculatedWeight = [[dict objectForKey:@"calculatedWeight"] floatValue];
    enviro.actualWeight = [[dict objectForKey:@"actualWeight"] floatValue];
    enviro.userDiversion = [[dict objectForKey:@"diversion"] floatValue];
    enviro.defaultDiversion = [[dict objectForKey:@"defaultDiversion"] floatValue];
    enviro.isSortable = NO;
    enviro.jobID = [[dict objectForKey:@"jobID"] integerValue];
    enviro.calculatedLoadSize = [[dict objectForKey:@"calculatedLoadSize"] floatValue];
    
    return enviro;
}

- (void)parseEnviroDict:(NSString*)responseString
{
    NSError *err = nil;

    // get the listing of environmental records for the jobs
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

    // create dictionary object that stores ...
    // - key: jobID
    // - value: an array of environment objects for that jobID
    NSMutableDictionary * enviroDict = [[NSMutableDictionary alloc] init];

    // check if job list still has data; if not, then retrieve it
    NSArray *jobList = [[DataStoreSingleton sharedInstance] jobList];

    // create array for each job
    for (int i = 0; i < jobList.count; i++)
    {
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        NSNumber * jobID = ((Job *)([jobList objectAtIndex:i])).jobID;
        [enviroDict setObject:newArray forKey:jobID];
    }

    // iterate through all the enviro for this route
    for (NSDictionary *dict in dataDict)
    {
        int jobID = [[dict objectForKey:@"jobID"] integerValue];
        
        // record the current enviro in the dictionary under the matching jobID
        Enviro * tempEnviro  = [self mapEnviro:dict];
        
        [[enviroDict objectForKey:[[NSNumber alloc] initWithInt:jobID]] addObject:tempEnviro];
    }
    
    self.enviroDict = enviroDict;
}

- (void)setEnviroDictFromJSON:(NSString*)responseString withJobID:(int)jobID
{
    
    // store the results in the enviro array; then add the final array into the eviroDict
    NSError *err;
    NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    NSMutableDictionary *enviroDict = self.enviroDict;
    
    [enviroDict removeObjectForKey:[[NSNumber alloc] initWithInt:jobID] ];
    NSMutableArray * enviroArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in results)
    {
        Enviro * enviro = [self mapEnviro:dict];
        [enviroArray addObject:enviro];
    }
    
    [enviroDict setObject:enviroArray forKey:[[NSNumber alloc] initWithInt:jobID]];
}

- (void)parseExpenseDict:(NSString*)responseString
{
    NSError *err = nil;
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    // create dictionary object that stores ...
    // - key: expenseTypeID
    // - value: an array of expenses under that expenseTypeID
    NSMutableDictionary * expensesDict = [[NSMutableDictionary alloc] init];
    
    // create array for expenseTypeIDs 1 - 3
    for (int i=1; i<=3; i++)
    {
        NSNumber * index = [[NSNumber alloc] initWithInt:i];
        [expensesDict setObject:[[NSMutableArray alloc] init] forKey:index];
    }
    
    // iterate through all the expenses for this route
    for (NSDictionary *dict in dataDict)
    {
        int expenseTypeID = [[dict objectForKey:@"expenseTypeID"] integerValue];
        
        
        // get the current expense, then insert it into
        // expensesDict at the appropriate location
        
        Expense *tempExpense  = [APIObjectConversionHelper mapExpense:dict];
        
        [[expensesDict objectForKey:[[NSNumber alloc] initWithInt:expenseTypeID]] addObject:tempExpense];
        
    }
    
    self.expensesDict = expensesDict;
}

- (PaymentMethod*)mapPaymentMethod:(NSDictionary*)dict
{
    PaymentMethod *newPayment = [[PaymentMethod alloc] init];
    
    newPayment.paymentID = [dict objectForKey:@"itemID"];
    newPayment.paymentName = [dict objectForKey:@"itemName"];
    
    return newPayment;
}

- (void)parsePaymentDict:(NSString*)responseString
{
    NSError *err = nil;
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    NSMutableArray *expensePaymentMethodsArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in dataDict)
    {
        [expensePaymentMethodsArray addObject:[self mapPaymentMethod:dict]];
    }

    self.paymentMethodList = expensePaymentMethodsArray;
}

- (void)parseJobDict:(NSString*)responseString
{
    self.pushJob = [self jobFromJsonString:responseString];
}

- (void)parseJobListDict:(NSString*)responseString routeID:(NSNumber*)routeID
{
    NSArray *jobListArray = [self jobsFromJsonString:responseString];
    [self addJobsList:jobListArray forRoute:routeID];
}

- (NSArray*)mergeJobsDict:(NSString*)responseString
{
    NSArray *jobListArray = [self jobsFromJsonString:responseString];
    [self mergeJobs:jobListArray];
    
    return jobListArray;
}


- (NSArray *)jobsFromJsonString:(NSString *)jsonString
{
    NSError *err = nil;
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
    
    NSMutableArray *jobs = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in dataDict)
    {
        [jobs addObject:[self mapJob:dict]];
    }
    return [NSArray arrayWithArray: jobs];
}

- (Job*)jobFromJsonString:(NSString *)jsonString
{
    NSError *err = nil;
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    return [self mapJob: dataDict];
}

- (Job*)mapJob:(NSDictionary*)dict
{
    Job *newJob = [[Job alloc] init];
    newJob.callAheadTime       = [dict objectForKey:@"callAheadTime"];
    newJob.clientCompany       = [dict objectForKey:@"companyName"];
    newJob.clientName          = [NSString stringWithFormat:@"%@ %@",[[dict objectForKey:@"contactFirstName"] capitalizedString],[[dict objectForKey:@"contactLastName"] capitalizedString] ];
    newJob.comments            = [dict objectForKey:@"jobComments"];
    newJob.jobDateAsString     = [dict objectForKey:@"jobDate"];
    newJob.programDiscount = [dict objectForKey:@"programDiscount"];
    newJob.programDiscountType = [dict objectForKey:@"programDiscountType"];
    newJob.promoCode = [dict objectForKey:@"promoCode"];
    newJob.zoneColor = [[dict objectForKey:@"zoneColor"] isKindOfClass:[NSString class]]? [dict objectForKey:@"zoneColor"]:@"";
    newJob.zoneFontColor =[dict objectForKey:@"zoneFontColor"];
    newJob.taxAmount =[dict objectForKey:@"taxAmount"];
    
    newJob.totalSpent     = [dict objectForKey:@"totalSpent"];
    newJob.total     = [dict objectForKey:@"total"];
    newJob.numOfJobs = [dict objectForKey:@"numOfJobs"];
    newJob.pickupAddress = [NSString stringWithFormat:@"#%@ %@\n%@, %@",[[dict objectForKey:@"pickupAptNo"] capitalizedString], [[dict objectForKey:@"pickupStreet"] capitalizedString],[[dict objectForKey:@"pickupCity"] capitalizedString],[[dict objectForKey:@"pickupState"] capitalizedString]];
    newJob.jobID               = [dict objectForKey:@"jobID"];
    newJob.routeID             = [dict objectForKey:@"routeID"];
    newJob.contactID           = [dict objectForKey:@"contactID"];
    newJob.promiseTime         = [dict objectForKey:@"promiseTime"];
    newJob.jobStartTime        = [dict objectForKey:@"jobStartTime"];
    newJob.clientEmail          = [dict objectForKey:@"contactEmail"];
    newJob.pickupCompany          = [dict objectForKey:@"pickupCompany"];
    newJob.zoneName          = [dict objectForKey:@"zoneName"];
    newJob.jobDuration         = [NSString stringWithFormat:@"%@", [dict objectForKey:@"jobDuration"]]; //[dict objectForKey:@"jobDuration"];
    if (![[dict objectForKey:@"clientEmail"] isKindOfClass:[NSNull class]])
        newJob.contactHomeExt= [dict objectForKey:@"clientEmail"] ;
    else
        newJob.contactHomeExt = @"";
    newJob.zipCode             = [dict objectForKey:@"pickupZipCode"];
    newJob.pickupCountry       = [dict objectForKey:@"pickupCountry"];
    newJob.discount            = [dict objectForKey:@"discount"];
    newJob.isCentrallyBilled   = [[dict objectForKey:@"isCentrallyBilled"] intValue] > 0;
    newJob.taxID               = [dict objectForKey:@"taxTypeID"];
    newJob.taxType             = [dict objectForKey:@"taxType"];
    newJob.isCashedOut         = [[dict objectForKey:@"isCashedOut"] intValue] > 0;
    newJob.jobStartTimeOriginal= [dict objectForKey:@"jobStartTime"];
    newJob.callAheadStatus     = [dict objectForKey:@"callAheadStatus"];
    newJob.subTotal            = [dict objectForKey:@"subtotal"];
    newJob.paymentID           = [dict objectForKey:@"paymentMethodID"];
    newJob.invoiceNumber       = [dict objectForKey:@"invoiceNumber"];
    newJob.dispatchMessage     = [dict objectForKey:@"dispatchMessage"];
    newJob.typeID              = [dict objectForKey:@"typeID"];
    newJob.jobType             = [dict objectForKey:@"jobTypeID"];
    newJob.nameOfLastTTUsed = [dict objectForKey:@"nameOfLastTTUsed"];
    newJob.npsValue = [dict objectForKey:@"npsValue"];
    if (![[dict objectForKey:@"npsComment"] isKindOfClass:[NSNull class]])
        newJob.npsComment= [dict objectForKey:@"npsComment"] ;
    else
        newJob.npsComment = @"";
    newJob.contactHomeAreaCode = [dict objectForKey:@"contactHomeAreaCode"];
    newJob.clientTypeID = [dict objectForKey:@"clientTypeID"];
    if (![[dict objectForKey:@"contactHomeExt"] isKindOfClass:[NSNull class]])
        newJob.contactHomeExt= [dict objectForKey:@"contactHomeExt"] ;
    else
        newJob.contactHomeExt = @"";
    newJob.contactHomePhone= [dict objectForKey:@"contactHomePhone"];
    newJob.contactPagerExt= [dict objectForKey:@"contactPagerExt"];
    if (![[dict objectForKey:@"contactPagerAreaCode"] isKindOfClass:[NSNull class]])
        newJob.contactPagerPhone= [dict objectForKey:@"contactPagerAreaCode"] ;
    else
        newJob.contactPagerPhone = @"";
    if (![[dict objectForKey:@"contactPagerPhone"] isKindOfClass:[NSNull class]])
        newJob.contactPagerPhone= [dict objectForKey:@"contactPagerPhone"] ;
    else
        newJob.contactPagerPhone = @"";
    newJob.programNotes= [dict objectForKey:@"programNotes"];
    
    newJob.contactWorkExt= [dict objectForKey:@"contactWorkExt"];
    newJob.contactWorkAreaCode= [dict objectForKey:@"contactWorkAreaCode"];
    newJob.contactWorkPhone= [dict objectForKey:@"contactWorkPhone"];
    newJob.contactFax= [dict objectForKey:@"contactFaxPhone"];
    newJob.contactFaxExt= [dict objectForKey:@"contactFaxExt"];
    newJob.contactFaxAreaCode= [dict objectForKey:@"contactFaxAreaCode"];
    newJob.contactCell = [dict objectForKey:@"contactCellPhone"];
    newJob.contactCellExt = [dict objectForKey:@"contactCellExt"];
    newJob.contactCellAreaCode = [dict objectForKey:@"contactCellAreaCode"];
    newJob.junkCharge = [dict objectForKey:@"junkCharge"];
    newJob.contactPhonePrefID = [dict objectForKey:@"contactPhonePrefID"];
    newJob.contactPhonePref= [dict objectForKey:@"contactPhonePref"];
    newJob.onSiteContactID= [dict objectForKey:@"onSiteContactID"];
    newJob.onSiteContactAreaCode= [dict objectForKey:@"onSiteContactAreaCode"];
    newJob.onSiteContactPhone= [dict objectForKey:@"onSiteContactPhone"];
    newJob.onSiteContactExt= [dict objectForKey:@"onSiteContactExt"];
    newJob.onSiteContactPhonePrefID= [dict objectForKey:@"onSiteContactPhonePrefID"];
    newJob.onSiteContactPhonePref= [dict objectForKey:@"onSiteContactPhonePref"];
    
    
    NSNumber *dispatchAccepted = [dict objectForKey:@"dispatchAccepted"];
    newJob.dispatchAccepted    = [dispatchAccepted boolValue];
    
    NSNumber *isEnviroRequired = [dict objectForKey:@"isEnviroRequired"];
    newJob.isEnviroRequired    = [isEnviroRequired boolValue];
    
    
    NSDate *dateFromString = [DateHelper dateFromMinutesSinceMidnight:[newJob.jobStartTime integerValue] andDayAsString:newJob.jobDateAsString];
    newJob.jobDate = dateFromString;
    
    NSInteger hours   = [newJob.jobStartTime integerValue] / 60;
    NSInteger minutes = [newJob.jobStartTime integerValue] % 60;
    BOOL amStartTime = NO;
    BOOL amEndTime = NO;
    
    if (hours > 12)
    {
        hours = hours - 12;
        amStartTime = NO;
    }
    else
        amStartTime = YES;
    if (hours == 12)
        amStartTime = NO;
    NSInteger endHours = ([newJob.jobStartTime integerValue] + [newJob.jobDuration integerValue])/60;
    NSInteger endMinutes = ([newJob.jobStartTime integerValue] + [newJob.jobDuration integerValue])%60;
    
    if (endHours > 12)
    {
        endHours = endHours - 12;
        amEndTime = NO;
    }
    else
        amEndTime = YES;
    if (endHours == 12)
        amEndTime = NO;
    if (minutes < 10)
    {
        if (amStartTime)
            newJob.jobStartTime = [NSString stringWithFormat:@"%d:0%d AM", hours, minutes];
        else
            newJob.jobStartTime = [NSString stringWithFormat:@"%d:0%d PM", hours, minutes];
        
    }
    else
    {
        if (amStartTime)
            newJob.jobStartTime = [NSString stringWithFormat:@"%d:%d AM", hours, minutes];
        else
            newJob.jobStartTime = [NSString stringWithFormat:@"%d:%d PM", hours, minutes];
        
    }
    if (endMinutes < 10)
    {
        if (amEndTime)
            newJob.jobEndTime = [NSString stringWithFormat:@"%d:0%d AM", endHours, endMinutes];
        else
            newJob.jobEndTime = [NSString stringWithFormat:@"%d:0%d PM", endHours, endMinutes];
        
    }
    else
    {
        if (amEndTime)
            newJob.jobEndTime = [NSString stringWithFormat:@"%d:%d AM", endHours, endMinutes];
        else
            newJob.jobEndTime = [NSString stringWithFormat:@"%d:%d PM", endHours, endMinutes];
        
    }
    
    newJob.dispatchID = [dict objectForKey:@"dispatchID"];
    newJob.isDispatchAccepted = [dict objectForKey:@"isDispatchAccepted"];

    [newJob parseOutLocationComments];
    
    newJob.apiJob = dict;
    
    return newJob;
}

- (void)setResourcesLocations
{
    for (Resource* resource in self.resourcesList)
    {
        if( resource == nil )
        {
            continue;
        }
        
        if( resource.mapPoint != nil )
        {
            continue;
        }
        
        NSString *rAddress = [resource getAddress];
        
        //NSLog(@"rAddress is %@", rAddress);
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:rAddress
                     completionHandler:^(NSArray* placemarks, NSError* error)
                    {
                        for (CLPlacemark* aPlacemark in placemarks)
                        {
                            CLLocationCoordinate2D placeCoord;
                            placeCoord.latitude = aPlacemark.region.center.latitude;
                            placeCoord.longitude = aPlacemark.region.center.longitude;
                            
                            resource.longitude = aPlacemark.region.center.longitude;
                            resource.latitude = aPlacemark.region.center.latitude;
                            
                            MapPoint *mapP = [[MapPoint alloc] initWithName:resource.resourceName address:rAddress coordinate:placeCoord andResourceID:resource.resourceTypeID];
                            resource.mapPoint = mapP;

                        }
                    }];
    }
}

- (void)setJobLocations
{
    for (Job* job in self.jobList)
    {
        if( job.mapPoint != nil )
        {
            continue;
        }
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        NSString *jAddress = job.pickupAddress;
        
        //NSLog(@"jAddress is %@", jAddress);
        
        [geocoder geocodeAddressString:jAddress
                     completionHandler:^(NSArray* placemarks, NSError* error)
         {
             for (CLPlacemark* aPlacemark in placemarks)
             {
                 //NSLog(@"    aPlacemark.longitude %f", aPlacemark.region.center.longitude);

                 CLLocationCoordinate2D placeCoord;
                 placeCoord.latitude = aPlacemark.region.center.latitude;
                 placeCoord.longitude = aPlacemark.region.center.longitude;
                 
                 NSString * nameString = [NSString stringWithFormat:@"%@ at %@", job.clientName, job.jobStartTime];
                 MapPoint *mapP = [[MapPoint alloc] initWithName:nameString address:jAddress coordinate:placeCoord andResourceID: 5];

                 job.mapPoint = mapP;
                 
             }
         }];
    }
}

- (int)getCurrentNotificationPageNumber
{
    return currentNotificationPageNumber;
}

- (void)incrementCurrentNotificationPageNumber
{
    currentNotificationPageNumber++;
}

- (void)decrementCurrentNotificationPageNumber
{
    if( currentNotificationPageNumber > 0 )
    {
        currentNotificationPageNumber--;
    }
}

- (Job*)getJob:(int)jobId
{
    // look up the dispatch's job from the list of jobs on the schedule
    if (self.jobList && self.jobList.count > 0)
    {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"jobID = %d", jobId]] ;
        
        NSArray * searchResults = [self.jobList filteredArrayUsingPredicate:predicate];
        if (searchResults && searchResults.count > 0)
        {
            return ((Job *)([searchResults objectAtIndex:0]));
            
        }
    }
    
    return nil;
}

-(void)runAsync:(void (^)(void))asyncBlock
{
    dispatch_queue_t bq = dispatch_queue_create("async block",NULL);
    dispatch_async(bq,asyncBlock);
}


@end
