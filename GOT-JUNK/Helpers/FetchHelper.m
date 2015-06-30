//
//  FetchHelper.m
//  GOT-JUNK
//
//  Created by epau on 1/30/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import <Parse/Parse.h>

#import "FetchHelper.h"

#import "APIDataConversionHelper.h"
#import "APIObjectConversionHelper.h"
#import "HTTPClientSingleton.h"
#import "JSONParserHelper.h"
#import "UserDefaultsSingleton.h"
#import "DataStoreSingleton.h"
#import "Franchise.h"
#import "DateHelper.h"
#import "PaymentMethod.h"
#import "Route.h"
#import "ExpenseAccount.h"
#import "TaxType.h"
#import "EnviroDestination.h"
#import "JunkType.h"
#import "Payment.h"
#import "Dispatch.h"
#import "Resource.h"
#import "AppDelegate.h"
#import "Enviro.h"
#import "Flurry.h"
#import "Notification.h"

@implementation FetchHelper
{
    BOOL isCaching;
    BOOL isFetching;
    HTTPClientSingleton *httpManager;
}

+ (FetchHelper *)sharedInstance
{
    static FetchHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        _sharedInstance = [[FetchHelper alloc] initFetchHelper];
    });

    return _sharedInstance;
}

- (id)initFetchHelper
{
  self = [super init];
  if (self)
  {
      httpManager = [HTTPClientSingleton sharedInstance];

      isCaching = NO;
      isFetching = NO;
      
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllCachingData) name:@"CoreDataReady" object:nil];
  }

  return self;
}

- (void)startNeworkActivity
{
    isFetching = YES;
    
    dispatch_async( dispatch_get_main_queue(), ^
                   {
                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                   });
}

- (void)endNetworkActivity
{
    isFetching = NO;
    
    dispatch_async( dispatch_get_main_queue(), ^
                   {
                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                   });
}

- (void) GNLog:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

- (void)sendNotification:(NSString*)note
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:note object:nil];
    });
}

- (void)login:(NSString*)username withPassword:(NSString*)password
{
    [self startNeworkActivity];

    // Modified by Thomas Chuah on March 4, 2013
    // Encode password before sending it through to the webservice.
    // This is to retain any special characters (e.g. @%#) that the password may contain.
    NSString * encodedPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)password,NULL,CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    //NSLog(@"Encoded password: %@", encodedPassword);
    
    NSString *path = [NSString stringWithFormat:@"v1/Login?username=%@&password=%@", username, encodedPassword];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            [self loginSucceededWithResponseString:operation.responseString andUsername:username];
                        }
                        else
                        {
                            NSLog(@"login error: %@", operation.responseString);
                        
                            [self sendNotification:@"FetchLoginFailed"];
                        }
                    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"login error: %@", operation.responseString);
                        
                        [self sendNotification:@"FetchLoginFailed"];
                    }];
}

- (void)clearUsernamePassword
{
    [httpManager clearUsernameAndPassword];
}

- (void)clearChannels
{
    [[UserDefaultsSingleton sharedInstance] setUserSessionID:@""];

    PFInstallation *ci = [PFInstallation currentInstallation];
    
    NSArray *subscribedChannels = ci.channels;
    for (NSString *channelName in subscribedChannels)
    {
        if( channelName != nil )
        {
            [ci removeObject:channelName forKey:@"channels"];
        }
    }
    [ci saveInBackground];
}

- (void)loginSucceededWithResponseString:(NSString*)response andUsername:(NSString *)username
{
    
    [[UserDefaultsSingleton sharedInstance] clearAllData];
    [[DataStoreSingleton sharedInstance] deleteAllData];
    [[UserDefaultsSingleton sharedInstance] setInstalled];

    NSLog(@"LOGIN SUCCESSFUL. RESPONSE: %@", response);
    
    NSError *err = nil;
    PFInstallation *currentParseInstallation = [PFInstallation currentInstallation];
    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    // access the dictionaries
    
    // TODO: Check these integer conversions. Seems like a bug to me...
    NSArray *assignedRoutes = [dataDict objectForKey:@"assignedRoutes"];
    NSString *permissions = [dataDict objectForKey:@"permissions"];
    NSString *nowString =  [DateHelper nowString];  //todays date
    
    if( [assignedRoutes isKindOfClass:[NSArray class]] == NO )
    {
        [Flurry logEvent:@"Warning: AssignedRoutes is not an array type." withParameters:nil];

        assignedRoutes = nil;
    }
    if( [permissions isKindOfClass:[NSString class]] == NO )
    {
        [Flurry logEvent:@"Warning: 'permissions' is not an NSString type." withParameters:nil];

        permissions = @"";
    }
    
    //[currentParseInstallation saveInBackground];
    
    if (assignedRoutes == nil || (([assignedRoutes count] < 1) && ( [permissions isEqualToString:@"Truck Team Member"])))
    {
        UIAlertView *failedLoginAlert = [[UIAlertView alloc] initWithTitle:@"No Assigned Route" message:@"Please get your supervisor to assign you to a route" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [failedLoginAlert show];
    }
    else
    {
        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary * myDict in assignedRoutes)
        {
            Route *tempRoute = [[Route alloc] init];
            tempRoute.routeID = [myDict objectForKey:@"routeID"];
            tempRoute.routeName = [myDict objectForKey:@"routeName"];
            [tempArray addObject:tempRoute];
            NSDate * date = [DataStoreSingleton sharedInstance].currentDate;
            [self fetchEnviroByRoute:[tempRoute.routeID intValue] onDate:date];
            NSString * ttmString = [NSString stringWithFormat:@"ittm%@%@",tempRoute.routeID,nowString];
            [currentParseInstallation addUniqueObject:ttmString forKey:@"channels"];
        }
        
        NSString *sessionID = [dataDict objectForKey:@"sessionID"];
        NSNumber *userID = [NSNumber numberWithInt:  [[dataDict objectForKey:@"userID"] integerValue]];
        NSString *fullName = [dataDict objectForKey:@"fullName"];
        NSNumber *defaultRouteID = [dataDict objectForKey:@"defaultRouteID"];
        NSString *defaultRouteName = [dataDict objectForKey:@"defaultRoute"];
        NSNumber *defaultFranchiseID = [dataDict objectForKey:@"defaultFranchiseID"];
        NSString *franchiseName = [dataDict objectForKey:@"defaultFranchise"];
        
        if (![permissions isEqualToString:@"Truck Team Member"])
        {
            NSString *franchiseSubscription = [NSString stringWithFormat:@"ifranchise%@", defaultFranchiseID];
            [currentParseInstallation addUniqueObject:franchiseSubscription forKey:@"channels"];
        }
        
        NSString *franchiseAll =[NSString stringWithFormat:@"franchise%@ALL", defaultFranchiseID];
        [currentParseInstallation addUniqueObject:franchiseAll forKey:@"channels"];
        
        [currentParseInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
            {
                if (succeeded)
                {
                    NSLog(@"Parse Saved.");
                }
                else
                {
                    NSLog(@"Parse Errir: %@", error);
                }
            }];
        
        Franchise * franchise = [[Franchise alloc] init];
        franchise.franchiseName = franchiseName;
        franchise.franchiseID = defaultFranchiseID;
        [DataStoreSingleton sharedInstance].permissions= permissions;
        [DataStoreSingleton sharedInstance].assignedRoutes= tempArray;
        [DataStoreSingleton sharedInstance].currentFranchise= franchise;
        
        UserDefaultsSingleton *defaults = [UserDefaultsSingleton sharedInstance];
        [defaults setUserSessionID:sessionID];
        [defaults setUserID:userID];
        [defaults setUserPermissions:permissions];
        [defaults setUserFullName:fullName];
        [defaults setDefaultFranchiseName:franchiseName];
        [defaults setUserDefaultRouteID:defaultRouteID];
        [defaults setUserDefaultRouteName:defaultRouteName];
        [defaults setUserDefaultFranchiseID:defaultFranchiseID];
        [defaults setUserLogin: username];
    }
    
    [DataStoreSingleton sharedInstance].isUserLoggedIn = YES;

    [self sendNotification:@"FetchLoginSuccess"];

    [self getAllCachingData];
}

- (void)getSystemInfo
{
    [self startNeworkActivity];

    //example api Call for Version check
    //https://apidev.1800gotjunk.com/Version?deviceType=iphone&sessionID=f4c88d6b-edee-4f96-8a9c-be70d20b92b7&currentVersion=1.1
    
    NSString *path = [NSString stringWithFormat:@"v1/SystemInfo"];
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSLog(@"getSystemInfo: %@",operation.responseString);
                            
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSString * tempString = [dataDict objectForKey:@"feedBackEmail"];
                            [[UserDefaultsSingleton sharedInstance] setFeedbackEmail:tempString];
                        }
                        else
                        {
                            NSLog(@"getSystemInfo Error: %@", operation.responseString);

                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                    }];
}

/*
 * Generic method for doing lookups of any sort
 */
- (void)fetchLookup:(NSString *)mode itemID:(int)i languageID:(int)l userID:(int)u
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"v1/Lookup/%@?%@&languageID=%d&itemID=%d&userID=%d", mode, [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath], l, i, u];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];


                            NSMutableArray *lookupArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [lookupArray addObject:[self mapLookup:dict]];
                            }

                            [DataStoreSingleton sharedInstance].lookupList = lookupArray;
                            
                            [self sendNotification:@"FetchLookupListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchLookup failed: %@", operation.responseString );
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchLookup failed: %@", operation.responseString );
                    
                        [self sendNotification:@"FetchLookupListComplete"];
                    }];
}

- (void)fetchLoadTypeSizes
{
    [self startNeworkActivity];

    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Lookup/LOADTYPESIZE?sessionID=%@", sessionID];
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSLog(@"fetchLoadTypeSizes succeeded: %@", operation.responseString);
                            NSError *err = nil;

                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSMutableArray *loadTypeSizeList = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [loadTypeSizeList addObject:[APIObjectConversionHelper mapLoadTypeSize:dict]];
                            }

                            [DataStoreSingleton sharedInstance].loadTypeSizeList = loadTypeSizeList;
                            
                            [self sendNotification:@"FetchLoadTypeSizeListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchLoadTypeSizes failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchLoadTypeSizes failed: %@", operation.responseString);
                    }];
}

- (void)fetchResources:(int)resourceTypeID
{
    NSString *sessionID = [self getAndPerformSessionIDActions];
    if( sessionID == nil )
    {
        return;
    }

    [self startNeworkActivity];
   
    NSNumber *franchiseID = [[UserDefaultsSingleton sharedInstance] getUserDefaultFranchiseID];
    NSString * path = [NSString stringWithFormat:@"v1/Franchise/%d/Resources?sessionID=%@", [franchiseID intValue], sessionID];
    
    // if resourceTypeID filter is applied, then add it to the endpoint string
    if (resourceTypeID > 0)
    {
        path = [NSString stringWithFormat:@"%@&resourceTypeID=%d", path, resourceTypeID];
    }
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                       
                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                            
                            NSMutableArray *resourcesArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [resourcesArray addObject:[APIObjectConversionHelper mapResource:dict withID:franchiseID]];
                            }
                            
                            [DataStoreSingleton sharedInstance].resourcesList = resourcesArray;
                            
                            [self sendNotification:@"FetchResourcesListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchResources failed: %@", operation.responseString);
                        }
                    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        NSLog(@"fetchResources failed: %@", operation.responseString);
                    }];
}

- (void)fetchEnviroByRoute:(int)routeID onDate:(NSDate *)date
{
    [self startNeworkActivity];

    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString * path = [NSString stringWithFormat:@"v1/Route/%d/Environmental?sessionID=%@&dayID=%@", routeID, sessionID, [DateHelper dateToApiString:date]];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            [[DataStoreSingleton sharedInstance] parseEnviroDict:operation.responseString];

                            [self sendNotification:@"FetchEnviroListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchEnviroByRoute failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        NSLog(@"fetchEnviroByRoute failed: %@", operation.responseString);
                    }];
}

- (void)fetchPaymentsByJob:(int)jobID
{
    [self startNeworkActivity];

    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%d/Payments?sessionID=%@", jobID, sessionID];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSError *err = nil;

                            // deserialize the JSON response into a dictionary
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSMutableArray *paymentArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [paymentArray addObject:[self mapPayment:dict]];
                            }

                            [DataStoreSingleton sharedInstance].paymentList = paymentArray;

                            [self sendNotification:@"FetchPaymentsListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchPaymentsByJob failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        NSLog(@"fetchPaymentsByJob failed: %@", operation.responseString);
                    }];
}

- (void)fetchExpensesByRoute:(int)routeID onDate:(NSDate *)date
{
    if( [self isAllowFetching] == NO )
    {
        [self sendNotification:@"FetchExpensesListComplete"];
        return;
    }

    [self startNeworkActivity];
   
    NSString *dateString = [DateHelper dateToApiString:date];
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Route/%d/Expenses?sessionID=%@&dayID=%@", routeID, sessionID, dateString];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self handleGeneralSuccessFetch:operation];

                        if (operation.responseString)
                        {
                            [[DataStoreSingleton sharedInstance] parseExpenseDict:operation.responseString];

                            [self sendNotification:@"FetchExpensesListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchExpensesByRoute failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self checkFailedError:operation withError:error callingMethod:@"fetchExpensesByRoute: "];
                        
                        NSLog(@"fetchExpensesByRoute failed: %@", operation.responseString);
                    }];
}

- (void)fetchJobListForRoute:(NSNumber *)routeID andDate:(NSDate *)date withAlert:(BOOL)shouldShowAlert
{
    NSString *sessionID = [self getAndPerformSessionIDActions];
    [self startNeworkActivity];

    NSString *dateString = [DateHelper dateToApiString:date];
    NSString *path = [NSString stringWithFormat:@"v1/Route/%d/Job?sessionID=%@&dayID=%@", [routeID integerValue], sessionID, dateString];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self handleGeneralSuccessFetch:operation];

                        if (operation.responseString)
                        {
                            NSArray *jobListArray = [[DataStoreSingleton sharedInstance] mergeJobsDict:operation.responseString];
                            
                            if (shouldShowAlert)
                            {
                                [self sendNotification:@"FetchJobListCompleteShowAlert"];
                            }
                            else
                            {
                                for (Job *j in jobListArray)
                                {
                                    if (!j.dispatchAccepted)
                                    {
                                        [[UserDefaultsSingleton sharedInstance] markJobAsSeenButNotAccepted:j.jobID];
                                    }
                                }
                                
                                [self sendNotification:@"FetchJobListComplete"];
                            }
                        }
                        else
                        {
                            NSLog(@"fetchJobListForRoute failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self checkFailedError:operation withError:error callingMethod:@"fetchJobListForRoute: "];
                        
                        NSLog(@"fetchJobListForRoute failed: %@", operation.responseString);
                    }];
    
}

- (void)fetchJobListForDefaultRouteAndCurrentDate
{
    if (!isFetching)
    {
        Route *route = [[DataStoreSingleton sharedInstance] currentRoute];
        NSNumber *routeID = (route != nil) ? route.routeID : [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];
        
        NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
        if (!currentDate)
        {
            currentDate = [DateHelper now];
        }

        [self fetchJobListForRoute:routeID andDate:currentDate withAlert:YES];
    }
}

- (void)fetchExpensePaymentMethods
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"v1/Lookup/%@?%@", @"PAYMENTMETHODEXPENSE", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath]];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            [[DataStoreSingleton sharedInstance] parsePaymentDict:operation.responseString];
                            
                            [self sendNotification:@"FetchExpensePaymentMethodsListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchExpensePaymentMethods failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        NSLog(@"fetchExpensePaymentMethods failed: %@", operation.responseString);
                    }];

}

- (void)fetchRouteList
{
    return [self fetchRouteList:[DateHelper now]];
}

- (void)fetchRouteList:(NSDate*)date
{
    if( [self isAllowFetching] == NO )
    {
        [self sendNotification:@"FetchRouteListComplete"];
        return;
    }
    
    NSString *sessionID = [self getAndPerformSessionIDActions];
    if( sessionID == nil )
    {
        return;
    }
    
    [self startNeworkActivity];
    
    NSString *dateString = [DateHelper dateToApiString: date];
    NSString *path = [NSString stringWithFormat:@"v1/Lookup/%@?%@&itemID=%@", @"JOBSPERROUTE", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath], dateString];
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self handleGeneralSuccessFetch:operation];

                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                            
                            NSMutableArray *routeListArray = [[NSMutableArray alloc] init];
                            
                            for (NSDictionary *dict in dataDict)
                            {
                                [routeListArray addObject:[self mapRoute:dict]];
                            }
                            
                            [DataStoreSingleton sharedInstance].routeList = routeListArray;

                            [self cachingRouteListComplete];

                            [self sendNotification:@"FetchRouteListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchRouteList failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self checkFailedError:operation withError:error callingMethod:@"fetchRouteList: "];
                        
                        NSLog(@"fetchRouteList failed: %@", operation.responseString);
                    }];
}

- (void)fetchFranchiseList
{
    return [self fetchFranchiseList:[DateHelper now]];
}

- (void)fetchFranchiseList:(NSDate*)date
{
    [self startNeworkActivity];

    NSString *dateString = [DateHelper dateToApiString:date];
    NSString *path = [NSString stringWithFormat:@"v1/Lookup/%@?%@&itemID=%@&userID=%@", @"FRANSIGNED", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath], dateString, [[UserDefaultsSingleton sharedInstance] getUserID]];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSMutableArray *franchiseListArray = [[NSMutableArray alloc] init];
                            
                            for (NSDictionary *dict in dataDict)
                            {
                                [franchiseListArray addObject:[self mapFranchise:dict]];
                            }

                            [DataStoreSingleton sharedInstance].franchiseList = franchiseListArray;
                            
                            [self sendNotification:@"FetchFranchiseListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchFranchiseList failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchFranchiseList failed: %@", operation.responseString);
                    }];
}

- (void)fetchJobDetaislForJob:(NSNumber*)jobID
{
    [self startNeworkActivity];

    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%d?sessionID=%@", [jobID integerValue], sessionID];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            [[DataStoreSingleton sharedInstance] parseJobDict:operation.responseString];
                            
                            [self sendNotification:@"needToDisplayJob"];
                        }
                        else
                        {
                            NSLog(@"fetchJobDetaislForJob [%d] failed: %@", [jobID intValue], operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchJobDetaislForJob [%d] failed: %@", [jobID intValue], operation.responseString);
                    }];
}

- (void)fetchExpenseAccountsList:(int)expenseTypeID
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"v1/Lookup/%@?%@&itemID=%d", @"FRANCHISEEXPENSE", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath], expenseTypeID];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSMutableArray *expenseAccountsListArray = [[NSMutableArray alloc] init];
                            
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                            for (NSDictionary *dict in dataDict)
                            {
                                [expenseAccountsListArray addObject:[self mapExpenseAccount:dict]];
                            }
                            
                            [DataStoreSingleton sharedInstance].expenseAccountsList = expenseAccountsListArray;
                            
                            [self sendNotification:@"FetchExpenseAccountsListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchExpenseAccountsList failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchExpenseAccountsList failed: %@", operation.responseString);
                    }];
}

- (void)fetchTaxTypes
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"Lookup/TAXTYPE?%@&itemID=0", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath]];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSArray *taxListData = [JSONParserHelper arrayFromJSONString:operation.responseString forKeyword:@"Data"];

                            NSMutableArray *taxListArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in taxListData)
                            {
                                [taxListArray addObject:[self mapTax:dict]];
                            }
                            
                            [DataStoreSingleton sharedInstance].taxList = taxListArray;
                            
                            [self sendNotification:@"FetchTaxListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchTaxTypes failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchTaxTypes failed: %@", operation.responseString);
                    }];
}

- (void)fetchJunkTypes
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"v1/Lookup/ENVIRONMENTJUNKTYPE?%@", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath] ];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSMutableArray *junkTypesListArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [junkTypesListArray addObject:[self mapJunkType:dict]];
                            }

                            [DataStoreSingleton sharedInstance].junkTypesList = junkTypesListArray;

                            [self sendNotification:@"FetchJunkTypesListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchJunkTypes failed: %@", operation.responseString);

                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                    
                        NSLog(@"fetchJunkTypes failed: %@", operation.responseString);
                    }];
}


- (void)fetchEnviroDestinations
{
    [self startNeworkActivity];

    NSString *path = [NSString stringWithFormat:@"v1/Lookup/ENVIRONMENTALDESTINATIONS?%@", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath] ];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSError *err = nil;
                            NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];

                            NSMutableArray *enviroDestinationsListArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in dataDict)
                            {
                                [enviroDestinationsListArray addObject:[self mapEnviroDestination:dict]];
                            }

                            [DataStoreSingleton sharedInstance].enviroDestinationsList = enviroDestinationsListArray;
                            
                            [self sendNotification:@"FetchDestinationListComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchEnviroDestinations failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        NSLog(@"fetchEnviroDestinations failed: %@", operation.responseString);
                    }];
}

- (void)fetchPaymentMethods
{
    [self startNeworkActivity];
    
    NSString *path = [NSString stringWithFormat:@"Lookup/%@?PAYMENTMETHOD&itemID=1", [[UserDefaultsSingleton sharedInstance] getUserSessionPermissionsPath]];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];

                        if (operation.responseString)
                        {
                            NSArray *paymentMethodData = [JSONParserHelper arrayFromJSONString:operation.responseString forKeyword:@"Data"];

                            NSMutableArray *paymentListArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *dict in paymentMethodData)
                            {
                                [paymentListArray addObject:[self mapPaymentMethod:dict]];
                            }

                            [DataStoreSingleton sharedInstance].paymentMethodList = paymentListArray;
                            
                            [self sendNotification:@"PaymentMethodListComplete"];

                        }
                        else
                        {
                            NSLog(@"fetchPaymentMethods failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        NSLog(@"fetchPaymentMethods failed: %@", operation.responseString);
                    }];
}

- (void)fetchDispatchesByRoute
{
    [self startNeworkActivity];
    
    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    int routeID = 0;
    if ([[DataStoreSingleton sharedInstance] currentRoute])
    {
        routeID = [[[DataStoreSingleton sharedInstance] currentRoute].routeID intValue];
    }
    else
    {
        routeID = [[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] integerValue];
    }
    
    // calculate the interval between midnight and current time
    int interval = [DateHelper secondsSinceMidnight];
    
    NSString *path = [NSString stringWithFormat:@"v1/Route/%d/Dispatch?sessionID=%@&interval=%d", routeID, sessionID, interval];
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            NSMutableArray *dispatchesList = [[NSMutableArray alloc] init];
                    
                            [DataStoreSingleton sharedInstance].dispatchesList = dispatchesList;
                        
                            [self sendNotification:@"FetchDispatchesComplete"];
                        }
                        else
                        {
                            NSLog(@"fetchDispatchesByRoute failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        [self sendNotification:@"FetchDispatchesFailed"];
                    
                        NSLog(@"fetchDispatchesByRoute failed: %@", operation.responseString);
                    }];
}

- (void)sendInvoice:(Job*)job paymentMethod:(NSInteger)pm junkCharge:(NSInteger)jc discount:(NSInteger)dc invoiceNumber:(NSInteger)inum taxID:(NSInteger)taxID
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSInteger routeID = 0;
    if ([[DataStoreSingleton sharedInstance] currentRoute])
    {
        routeID = [[[DataStoreSingleton sharedInstance] currentRoute].routeID integerValue];
    }
    else
    {
        routeID = [[[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID] integerValue];
    }

    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", pm], @"paymentMethodID",
                            [NSString stringWithFormat:@"%d", jc], @"junkCharge",
                            [NSString stringWithFormat:@"%d", dc], @"discount",
                            [NSString stringWithFormat:@"%d", inum], @"invoiceNumber",
                            job.jobDateAsString, @"dayID",
                            [NSString stringWithFormat:@"%d", routeID], @"routeID",
                            [NSString stringWithFormat:@"%d", taxID], @"taxID",
                            sessionID, @"sessionID",
                            nil];

    NSString *path = [NSString stringWithFormat:@"Job/%d/Payment", [job.jobID integerValue]];
    [httpManager postPath:path parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [self sendNotification:@"SendInvoiceCompleteSuccessful"];
                        }
                        else
                        {
                            [self sendNotification:@"SendInvoiceCompleteFailure"];

                            NSLog(@"sendInvoice failed: %@", operation.responseString);
                        }
                    }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        [self sendNotification:@"SendInvoiceCompleteFailure"];
                        
                        NSLog(@"sendInvoice failed: %@", operation.responseString);

                    }];
}

- (void)convertEstimate:(Job*)job
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            sessionID, @"sessionID",
                            nil];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%d/ConvertEstimateToJob?sessionID=%@", [job.jobID integerValue], sessionID];
    [httpManager putPath:path parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [self sendNotification:@"ConvertCompleteSuccessful"];
                        }
                        else
                        {
                            [self sendNotification:@"ConvertCompleteFailure"];
                            
                            NSLog(@"convertEstimate failed: %@", operation.responseString);
                        }
                    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        [self sendNotification:@"ConvertCompleteFailure"];
                        
                        NSLog(@"convertEstimate failed: %@", operation.responseString);
                    }];
}

- (void)updateEmail:(NSString*)email forJob:(Job*)job
{
    [self startNeworkActivity];

    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];

    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            sessionID, @"sessionID",
                            nil];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%d/UpdateContactEmail?email=%@&sessionID=%@", [job.jobID integerValue], email, sessionID];
    [httpManager putPath:path parameters:params
                success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [self sendNotification:@"UpdateEmailCompleteSuccessful"];
                        }
                        else
                        {
                            [self sendNotification:@"UpdateEmailCompleteFailure"];
                            
                            NSLog(@"updateEmail failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        [self sendNotification:@"UpdateEmailCompleteFailure"];
                        
                        NSLog(@"updateEmail failed: %@", operation.responseString);
                    }];
}

- (void)updateNote:(NSString*)comment forJob:(Job*)job
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    [job.apiJob setValue:comment forKey:@"jobComments"];

    NSString *path = [NSString stringWithFormat:@"v1/Job/%d/AppendJobComments?&sessionID=%@", [job.jobID integerValue], sessionID];
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager putPath:path parameters:job.apiJob
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [job appendCommentsAndJunkLocation:comment];
                            [job.apiJob setValue:job.comments forKey:@"jobComments"];

                            [self sendNotification:@"UpdateNoteCompleteSuccessful"];
                        }
                        else
                        {
                            [self sendNotification:@"UpdateNoteCompleteFailure"];
                            
                            NSLog(@"updateNote failed: %@", operation.responseString);
                        }
                    }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
    
                        [self sendNotification:@"UpdateNoteCompleteFailure"];

                        NSLog(@"updateNote failed: %@", operation.responseString);
                    }];
}

- (void)acceptDispatchForJob:(Job*)job
{
    [self startNeworkActivity];

    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];

    [httpManager setParameterEncoding:AFJSONParameterEncoding];

    NSString *path = [NSString stringWithFormat:@"v1/UpdateJobDispatchStatus?sessionID=%@", sessionID];
    [httpManager putPath:path parameters:job.apiJob
                success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [DataStoreSingleton sharedInstance].currentJob = [[DataStoreSingleton sharedInstance] jobFromJsonString:operation.responseString];
                            [self sendNotification:@"AcceptDispatchCompleteSuccessful"];
                        }
                        else
                        {
                            [self sendNotification:@"AcceptDispatchCompleteFailure"];
                            
                            NSLog(@"acceptDispatchForJob failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];
                        
                        [self sendNotification:@"AcceptDispatchCompleteFailure"];
                        
                        NSLog(@"acceptDispatchForJob failed: %@", operation.responseString);
                    }];
}

- (void)fetchJobListForEachRoute:(NSNumber *)routeID andDate:(NSDate *)date
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *dateString = [DateHelper dateToApiString: date];
    
    NSString *path = [NSString stringWithFormat:@"v1/Route/%d/Job?sessionID=%@&dayID=%@", [routeID integerValue], sessionID, dateString];

    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        [self endNetworkActivity];
                        
                        if (operation.responseString)
                        {
                            [[DataStoreSingleton sharedInstance] parseJobListDict:operation.responseString routeID:routeID];
                        }
                        else
                        {
                            NSLog(@"fetchJobListForEachRoute failed: %@", operation.responseString);
                        }
                    }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        [self endNetworkActivity];

                        NSLog(@"fetchJobListForEachRoute failed: %@", operation.responseString);
                    }];
    
}

- (void)fetchJobListsForAllRoutes
{
    NSDate *currentDate = [[DataStoreSingleton sharedInstance] currentDate];
    
    if (!currentDate)
    {
        currentDate = [DateHelper now];
    }
    
    NSNumber *defaultRouteID = [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteID];

    [[DataStoreSingleton sharedInstance] clearRouteJobs];
    
    for( Route *route in [DataStoreSingleton sharedInstance].routeList )
    {
        if( [route.routeID isEqualToNumber:defaultRouteID] == YES )
        {
            [DataStoreSingleton sharedInstance].currentRoute = route;
        }
        
        [self fetchJobListForEachRoute:route.routeID andDate:currentDate];
    }
}

- (void)getAllCachingData
{
    @try
    {
        NSLog(@"GET ALL CACHING DATA");
        isCaching = YES;
    
        [self fetchRouteList];
        [self fetchResources:0];
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_003" message:error exception:exception];
    }
}

- (void)cachingRouteListComplete
{
    if( isCaching == YES )
    {
        isCaching = NO;
        
        [self fetchFranchiseList];
        [self fetchJobListsForAllRoutes];
    }
}

- (void)checkAppUpgrade
{
    [self startNeworkActivity];

    NSString *appVersion = [UserDefaultsSingleton appVersion];
    NSString *path = [NSString stringWithFormat:@"v1/Version/?deviceType=iphone&currentVersion=%@", appVersion];
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                     {
                         [self endNetworkActivity];

                         if (operation.responseString)
                         {
                             NSString* thisString = operation.responseString;
                             NSDictionary *dataDict = [JSONParserHelper dictFromJSONString:thisString];
                             if( dataDict != nil )
                             {
                                 [DataStoreSingleton sharedInstance].appUpgradeInfo = dataDict;
                                 
                                 NSString *currentVersion = [dataDict objectForKey: @"currentVersion"];
                                 if( currentVersion != nil && [currentVersion isEqualToString:appVersion] == NO)
                                 {
                                     [self sendNotification:@"UpdateAvailable"];
                                 }
                             }
                         }
                         
                     }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
                     {
                         [self endNetworkActivity];
                         
                         [self checkFailedError:operation withError:error callingMethod:@"checkAppStatus: "];
                     }];
}

- (NSString*)getAndPerformSessionIDActions
{
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    
    if( sessionID == nil )
    {
        if( [DataStoreSingleton sharedInstance].isUserLoggedIn == YES )
        {
            
            [DataStoreSingleton sharedInstance].debugDisplayText1 = @"getAndPerformSessionIDActions";
            
            [DataStoreSingleton sharedInstance].isUserLoggedIn = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedSessionExpired" object:nil];
        }
        
        return nil;
    }
    
    return sessionID;
}

- (void)saveEnviro:(NSArray *)enviroArray isDeletion:(BOOL)isDelete forJobID:(int)jobID
{
    NSMutableArray * enviroArrayFinal = [[NSMutableArray alloc] init];
    for (int i=1; i<=2; i++) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"loadTypeID = %d", i];
        NSArray * matchingEnviroArray = [enviroArray filteredArrayUsingPredicate:predicate];
        
        if (!matchingEnviroArray || matchingEnviroArray.count == 0)
        {
            continue;
        }
        
        // go through all the enviro breakdowns and calculate the % of the total job that each one represents
        
        //matchingEnviroArray = [self setPercentOfJob:matchingEnviroArray];
        [self setPercentOfJob:matchingEnviroArray];
        
        // check that the percentOfJob was calculated
        
        [enviroArrayFinal addObjectsFromArray:matchingEnviroArray];
    }
    
    [self postEnvironmental:enviroArrayFinal isDeletion:isDelete forJobID:jobID];
}

- (NSArray *)setPercentOfJob:(NSArray *)enviroArray
{
    float allEnviroTruckloads = 0;
    int totalPercentage = 0;
    for (Enviro * e in enviroArray)
    {
        e.totalTruckSize = [self calculateTotalTruckloads:e];
        allEnviroTruckloads += e.totalTruckSize;
    }
    
    for (Enviro * e in enviroArray)
    {
        e.percentOfJob = roundf((e.totalTruckSize / allEnviroTruckloads) * 100);
    }
    
    // now add up all the percentage breakdowns and ensure it all adds up to 100%
    for (Enviro * e in enviroArray)
    {
        totalPercentage += e.percentOfJob;
    }
    
    if (totalPercentage != 100)
    {
        int delta = 100 - totalPercentage;
        Enviro * enviro = (Enviro *)([enviroArray objectAtIndex:(enviroArray.count - 1)]);
        enviro.percentOfJob += delta;
    }
    
    return enviroArray;
}

- (float)calculateTotalTruckloads:(Enviro *)enviro
{
    return enviro.numberOfTrucks + enviro.calculatedLoadSize;
}

// update existing enviro breakdowns
- (void)postEnvironmental:(NSArray *)enviroArray isDeletion:(BOOL)isDelete forJobID:(int)jobID
{
    [self startNeworkActivity];
    
    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString * path = [NSString stringWithFormat:@"v1/Job/%d/Environmental?sessionID=%@", jobID, sessionID];
    
    // assemble an array of the Enviro objects
    
    NSMutableArray *allParams = [[NSMutableArray alloc] init];
    
    for (Enviro * enviro in enviroArray)
    {
        NSDictionary *enviroParam = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%d", enviro.environmentCategorizationID], @"environmentCategorizationID",
                                     [NSString stringWithFormat:@"%d", enviro.loadTypeID], @"loadTypeID",
                                     [NSString stringWithFormat:@"%d", enviro.junkTypeID], @"junkTypeID",
                                     [NSString stringWithFormat:@"%.f", enviro.percentOfJob], @"percentOfJob",
                                     [NSString stringWithFormat:@"%d", enviro.destinationID], @"destinationID",
                                     [NSString stringWithFormat:@"%.f", enviro.actualWeight], @"actualWeight",
                                     [NSString stringWithFormat:@"%.f", enviro.calculatedWeight], @"calculatedWeight",
                                     [NSString stringWithFormat:@"%d", enviro.weightTypeID], @"weightTypeID",
                                     [NSString stringWithFormat:@"%d", enviro.loadTypeSizeID], @"loadTypeSizeID",
                                     [NSString stringWithFormat:@"%d", enviro.numberOfTrucks], @"numberOfTrucks",
                                     [NSString stringWithFormat:@"%.f", enviro.userDiversion], @"diversion",
                                     nil];
        [allParams addObject:enviroParam];
    }
    
    NSMutableDictionary *allParams1 = [[NSMutableDictionary alloc] init];
    [allParams1 setObject:allParams forKey:@""];
    
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager postPath:path parameters:allParams1
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [[DataStoreSingleton sharedInstance] setEnviroDictFromJSON:operation.responseString withJobID:jobID];
             
             [self sendNotification:isDelete ? @"SendDeleteEnvironmentalSuccessful" : @"SendUpdateEnvironmentalSuccessful"];
         }
         else
         {
             [self sendNotification:isDelete ? @"SendDeleteEnvironmentalFailure" : @"SendUpdateEnvironmentalFailure"];
             
             NSLog(@"postEnvironmental failed: %@", operation.responseString);
         }
     }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:isDelete ? @"SendDeleteEnvironmentalFailure" : @"SendUpdateEnvironmentalFailure"];
         
         NSLog(@"postEnvironmental failed: %@", operation.responseString);
         
     }];
    
}


// create expense
- (void)postExpense:(NSString *)path withParams:(NSDictionary *)params
{
    [self startNeworkActivity];
    
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager postPath:path parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             NSError * err = nil;
             NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
             
             // get the expenseID from the object that gets passed back, in case resource update fails and the user chooses to
             // submit the form again.  in such a situation, the fact we have an expenseID value will tell us we need to do
             // a put (update) and not a post (create).
             Expense* myExpense = [APIObjectConversionHelper mapExpense:results];
             
             [[DataStoreSingleton sharedInstance] addExpense:myExpense expenseTypeID:myExpense.expenseTypeID];
             
             [DataStoreSingleton sharedInstance].currentExpense = myExpense;
             
             [self sendNotification:@"SendCreateExpenseSuccessful"];
         }
         else
         {
             [self sendNotification:@"SendCreateExpenseFailure"];
             
             NSLog(@"postExpense failed: %@", operation.responseString);
         }
     }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self sendNotification:@"SendCreateExpenseFailure"];
         
         NSLog(@"postExpense failed: %@", operation.responseString);
     }];
}

// update expense or resource
- (void)putExpenseResource:(NSString *)path withParams:(NSDictionary *)params withMode:(SubmitMode)mode
{
    [self startNeworkActivity];
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager putPath:path parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             NSError * err = nil;
             NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
             
             if (mode == SubmitModeExpense)
             {
                 Expense *myExpense = [APIObjectConversionHelper mapExpense:results];
                 
                 NSMutableArray *expensesList = [[DataStoreSingleton sharedInstance].expensesDict objectForKey:[[NSNumber alloc] initWithInt:myExpense.expenseTypeID]];
                 
                 // update the existing expense in the expenses list
                 
                 for (int i=0; i<expensesList.count; i++)
                 {
                     Expense * expense = [expensesList objectAtIndex:i];
                     if (expense.expenseID == myExpense.expenseID)
                     {
                         [expensesList replaceObjectAtIndex:i withObject:myExpense];
                         break;
                     }
                 }
                 
                 [DataStoreSingleton sharedInstance].currentExpense = myExpense;
             }
             else
             { // just submitted resource coordinates
                 
                 Resource *myResource = [APIObjectConversionHelper mapResource:results withID:[NSNumber numberWithInt:0]];
                 
                 NSMutableArray * resourcesList = [DataStoreSingleton sharedInstance].resourcesList;
                 
                 for (int i =0; i<resourcesList.count; i++)
                 {
                     Resource *resource = [resourcesList objectAtIndex:i];
                     if (resource.resourceID == myResource.resourceID)
                     {
                         [resourcesList replaceObjectAtIndex:i withObject:myResource];
                     }
                 }
                 
                 [DataStoreSingleton sharedInstance].currentResource = myResource;
                 
             }
             
             [self sendNotification:(mode == SubmitModeExpense) ? @"SendUpdateExpenseSuccessful" : @"SendUpdateResourceSuccessful"];
         }
         else
         {
             [self sendNotification:(mode == SubmitModeExpense) ? @"SendUpdateExpenseFailure" : @"SendUpdateResourceFailure"];
             
             NSLog(@"putExpenseResource failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:(mode == SubmitModeExpense) ? @"SendUpdateExpenseFailure" : @"SendUpdateResourceFailure"];
         
         NSLog(@"putExpenseResource failed: %@", operation.responseString);
     }];
    
}

- (void)updateContactPhone:(NSNumber*)jobID withParams:(NSDictionary *)params
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/UpdateContactPhone?sessionID=%@",jobID, sessionID];
    
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager putPath:path parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [self sendNotification:@"UpdateContatPhoneSuccessful"];
         }
         else
         {
             [self sendNotification:@"UpdateContatPhoneFailure"];
             
             NSLog(@"updateContactPhone failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:@"UpdateContatPhoneFailure"];
         
         NSLog(@"updateContactPhone failed: %@", operation.responseString);
         
     }];
}

- (void)setDispatchStatus:(int)dispatchID
{
    [self startNeworkActivity];
    
    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString * path = [NSString stringWithFormat:@"v1/Dispatch/%d/ViewMode/VIEWED?sessionID=%@", dispatchID, sessionID];
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager putPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         NSLog(@"setDispatchStatus failed: %@", operation.responseString);
     }];
}

- (void)updateJob:(NSNumber*)jobID withDuration:(NSNumber*)jobDuration
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/UpdateJobDuration?sessionID=%@&jobDuration=%@", jobID, sessionID,[NSString stringWithFormat:@"%@", jobDuration] ];
    
    [httpManager putPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [self sendNotification:@"UpdateJobSuccessful"];
         }
         else
         {
             [self sendNotification:@"UpdateJobFailed"];
             
             NSLog(@"updateJob failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:@"UpdateJobFailed"];
         
         NSLog(@"updateJob failed: %@", operation.responseString);
     }];
}

- (void)copyMoveJob:(NSNumber*)jobID jobType:(NSString*)jobType routeID:(NSInteger)routeID jobStartTimeOriginal:(NSNumber*)jobStartTimeOriginal
{
    [self startNeworkActivity];
    
    NSDate *date = [[DataStoreSingleton sharedInstance] currentDate];
    NSString *dateString = [DateHelper dateToApiString:date];
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/%@?sessionID=%@&dayID=%@&routeID=%ld&timeStart=%@", jobID, jobType, sessionID, dateString, (long)routeID, jobStartTimeOriginal ];
    
    [httpManager putPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [self sendNotification:@"CopyMoveJobSuccessful"];
         }
         else
         {
             [self sendNotification:@"CopyMoveJobFailed"];
             
             NSLog(@"copyMoveJob failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:@"CopyMoveJobFailed"];
         
         NSLog(@"copyMoveJob failed: %@", operation.responseString);
     }];
}

- (void)deleteExpense:(Expense*)expenseToDelete withIndexPath:(NSIndexPath*)indexPath
{
    [self startNeworkActivity];
    
    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString * path = [NSString stringWithFormat:@"v1/Expense/%d?sessionID=%@&routeID=%d&dayID=%d", expenseToDelete.expenseID, sessionID, expenseToDelete.routeID, expenseToDelete.dayID];
    
    [httpManager deletePath:path
                 parameters:nil
                    success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             NSMutableArray *expensesList = [[DataStoreSingleton sharedInstance].expensesDict objectForKey:[[NSNumber alloc] initWithInt:(int)(indexPath.section + 1)]];
             [expensesList removeObjectAtIndex:indexPath.row];
             
             [self sendNotification:@"SendDeleteExpenseSuccesful"];
         }
         else
         {
             [self sendNotification:@"SendDeleteExpenseFailed"];
             
             NSLog(@"deleteExpense failed: %@", operation.responseString);
         }
     }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:@"SendDeleteExpenseFailed"];
         
         NSLog(@"deleteExpense failed: %@", operation.responseString);
     }];
}

- (void)cancelJob:(NSNumber*)jobID withReason:(int)reasonID periodID:(int)periodID comments:(NSString*)comments
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/Cancel?sessionID=%@", jobID, sessionID];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d", reasonID], @"cancelReasonID",
                            comments, @"cancelComments",
                            [NSString stringWithFormat:@"%d", periodID], @"cancelPeriodID",
                            nil];
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager putPath:path parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [self sendNotification:@"MustRefreshJobsList"];
             [self sendNotification:@"CancelJobSuccessful"];
         }
         else
         {
             [self sendNotification:@"CancelJobFailed"];
             
             NSLog(@"cancelJob failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [self sendNotification:@"CancelJobFailed"];
         
         NSLog(@"cancelJob failed: %@", operation.responseString);
     }];
}


- (void)setCallStatus:(NSNumber*)jobID statusID:(NSString*)senderString
{
    [self startNeworkActivity];
    
    NSString *sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];
    NSString *path = [NSString stringWithFormat:@"v1/Job/%@/CallAhead?callAheadStatusID=%@&sessionID=%@", jobID, senderString, sessionID];
    
    [httpManager putPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
     }];
}

- (void)postPayment:(NSString*)path params:(NSDictionary*)params
{
    [self startNeworkActivity];
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    [httpManager postPath:path parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if( operation.responseString )
         {
             [self sendNotification:@"PostPaymentSuccessful"];
         }
         else
         {
             [self sendNotification:@"PostPaymentFailed"];
             
             NSLog(@"postPayment failed: %@", operation.responseString);
         }
     }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [self endNetworkActivity];
         
         [DataStoreSingleton sharedInstance].paymentErrors = operation.responseString;
         
         [self sendNotification:@"PostPaymentFailed"];
         
         NSLog(@"postPayment failed: %@", operation.responseString);
     }];
}

//-------------------------=====================================================------------------------------------------

- (void)handleGeneralSuccessFetch:(AFHTTPRequestOperation*)operation
{
    [self endNetworkActivity];
    
    if (operation.responseString)
    {
        DataStoreSingleton *dataStore = [DataStoreSingleton sharedInstance];
        
        if( dataStore.isJunkNetLive == NO || dataStore.isInternetLive == NO || dataStore.isUserLoggedIn == NO )
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchTestSuccess" object:nil];
            });
            dataStore.isInternetLive = YES;
            dataStore.isJunkNetLive = YES;
            dataStore.isUserLoggedIn = YES;
            
            //[self getAllCachingData];
        }
    }
}

- (void)checkFailedError:(AFHTTPRequestOperation*)operation withError:(NSError*)error callingMethod:(NSString*)method
{
    [self endNetworkActivity];
    //NSLog(@"%@ %@", method, operation.responseString);
    
    if( [self checkInternetError:error forMessage:@"The Internet connection appears to be offline."] == YES )
    {
        return;
    }
    if( [self checkInternetError:error forMessage:@"The request timed out."] == YES )
    {
        return;
    }
    if( [self checkJunkNetError:error forMessage:@"The network connection was lost."] == YES )
    {
        return;
    }
    if( [self checkJunkNetError:error forMessage:@"Could not connect to the server."] == YES )
    {
        return;
    }
    

    [DataStoreSingleton sharedInstance].debugDisplayText1 = method;
    
    if( [self checkSessionError:error forMessage:@"Expected status code in (200-299), got 403"] == YES )
    {
        return;
    }
    if( [self checkSessionError:error forMessage:@"Expected status code in (200-299), got 401"] == YES )
    {
        return;
    }
    
    NSString *reason = operation.responseString;
    if( [reason isEqualToString:@"\"Unauthorized Request\""] == YES )
    {
        NSLog(@"checkFailedError: %@", reason);

        [self clearChannels];
    }
    
    
    // If execution reaches this point, the error is none of the above,
    // and, we need to assume it is either server down or no connection, both triggers Offline Mode.
    // Assume no connection.
    // There are many types of error associated with server down or no connection.
    // Interpreting the error based on error message is a bad idea.
    // TODO: REFACTORING NEEDED.
    if( [DataStoreSingleton sharedInstance].isInternetLive == YES )
    {
        [DataStoreSingleton sharedInstance].isInternetLive = NO;
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedNoInternet" object:nil];
        });
    }
    
}


- (BOOL)isAllowFetching
{
    return [DataStoreSingleton sharedInstance].isJunkNetLive == YES && [DataStoreSingleton sharedInstance].isInternetLive == YES;
}

- (BOOL)checkInternetError:(NSError*)error forMessage:(NSString*)messasge
{
    NSString *errorCause = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    if( [errorCause isEqualToString:messasge] == YES )
    {
        NSLog(@"checkInternetError: errorCause: %@", errorCause);
        if( [DataStoreSingleton sharedInstance].isInternetLive == YES )
        {
            [DataStoreSingleton sharedInstance].isInternetLive = NO;
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedNoInternet" object:nil];
            });
        }
        return YES;
    }
    
    if( [DataStoreSingleton sharedInstance].isInternetLive == NO )
    {
        [DataStoreSingleton sharedInstance].isInternetLive = YES;
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchInternetUp" object:nil];
        });
    }

    return NO;
}

- (BOOL)checkJunkNetError:(NSError*)error forMessage:(NSString*)messasge
{
    NSString *errorCause = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    if( [errorCause isEqualToString:messasge] == YES )
    {
        NSLog(@"checkJunkNetError: errorCause: %@", errorCause);
        if( [DataStoreSingleton sharedInstance].isJunkNetLive == YES )
        {
            [DataStoreSingleton sharedInstance].isJunkNetLive = NO;
            dispatch_async( dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedServerDown" object:nil];
            });
        }
        return YES;
    }
    
    if( [DataStoreSingleton sharedInstance].isJunkNetLive == NO )
    {
        [DataStoreSingleton sharedInstance].isJunkNetLive = YES;
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchServerUp" object:nil];
        });
    }
    
    return NO;
}

- (BOOL)checkSessionError:(NSError*)error forMessage:(NSString*)message
{
    NSString *errorCause = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    if( [errorCause isEqualToString:message] == YES )
    {
        NSLog(@"checkSessionError: errorCause: %@", errorCause);
        if( [DataStoreSingleton sharedInstance].isUserLoggedIn == YES )
        {
            [DataStoreSingleton sharedInstance].isUserLoggedIn = NO;
            
            [self clearChannels];

            dispatch_async( dispatch_get_main_queue(), ^{
                
                //[DataStoreSingleton sharedInstance].debugDisplayText1 = @"checkSessionError";
                [DataStoreSingleton sharedInstance].debugDisplayText2 = message;

                [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchFailedSessionExpired" object:nil];
            });
        }
        return YES;
    }
    
    return NO;
}

///=================================================================================

- (Route*)mapRoute:(NSDictionary*)dict
{
    Route *newRoute = [[Route alloc] init];
    newRoute.routeID = [dict objectForKey:@"itemID"];
    newRoute.routeName = [dict objectForKey:@"itemName"];
    newRoute.jobsInRoute = [dict objectForKey:@"jobCount"];
    return newRoute;
}

- (Franchise*)mapFranchise:(NSDictionary*)dict
{
    Franchise *newFranchise = [[Franchise alloc] init];
    newFranchise.franchiseID = [dict objectForKey:@"itemID"];
    newFranchise.franchiseName = [dict objectForKey:@"itemName"];
    return newFranchise;
}

- (TaxType*)mapTax:(NSDictionary*)dict
{
    TaxType *newTax = [[TaxType alloc] init];
    newTax.taxId = [dict objectForKey:@"lookUpID"];
    newTax.taxValue = [dict objectForKey:@"lookUpName"];
    return newTax;
}

- (ExpenseAccount*)mapExpenseAccount:(NSDictionary*)dict
{
    ExpenseAccount * newExpenseAccount = [[ExpenseAccount alloc] init];
    newExpenseAccount.expenseAccountID = [[dict objectForKey:@"itemID"] intValue];
    newExpenseAccount.expenseAccountName = [dict objectForKey:@"itemName"];
    return newExpenseAccount;
}

- (PaymentMethod*)mapPaymentMethod:(NSDictionary*)dict
{
    PaymentMethod *newPayment = [[PaymentMethod alloc] init];
    
    newPayment.paymentID = [dict objectForKey:@"itemID"];
    newPayment.paymentName = [dict objectForKey:@"itemName"];
    
    return newPayment;
}

-(Payment*)mapPayment:(NSDictionary*)dict
{
    Payment *payment = [[Payment alloc] init];
    payment.paymentAmount = [[dict objectForKey:@"paymentTotal"] floatValue] /100;
    payment.methodID = [dict objectForKey:@"paymentMethodID"] ;
    payment.jobID = [dict objectForKey:@"jobID"];
    payment.paymentID = [dict objectForKey:@"jobID"];
    payment.paymentName = [dict objectForKey:@"paymentMethod"];
    return payment;
}
- (Lookup*)mapLookup:(NSDictionary*)dict
{
    Lookup *lookup = [[Lookup alloc] init];
    lookup.itemID = [[dict objectForKey:@"itemID"] integerValue];
    lookup.itemName = [dict objectForKey:@"itemName"];
    
    return lookup;
}

- (JunkType *)mapJunkType:(NSDictionary *)dict
{
    JunkType * junkType = [[JunkType alloc] init];
    junkType.itemID = [[dict objectForKey:@"itemID"] integerValue];
    junkType.itemName = [dict objectForKey:@"itemName"];
    junkType.poundsPerCubicYard = [[dict objectForKey:@"poundsPerCubicYard"] floatValue];
    return junkType;
}

- (EnviroDestination*)mapEnviroDestination:(NSDictionary *)dict
{
    EnviroDestination * destination = [[EnviroDestination alloc] init];
    destination.itemID = [[dict objectForKey:@"itemID"] integerValue];
    destination.itemName = [dict objectForKey:@"itemName"];
    destination.diversionPercent = [[dict objectForKey:@"diversionPercent"] floatValue];
    destination.isSortable = [[dict objectForKey:@"isSortable"] boolValue];
    return destination;
}

- (void)fetchResourcesALL:(int)franchiseIndex
{
    NSString *sessionID = [self getAndPerformSessionIDActions];
    if( sessionID == nil )
    {
        return;
    }
    
    [self startNeworkActivity];
    
    NSNumber *franchiseID =  [NSNumber numberWithInt:franchiseIndex];//  [[UserDefaultsSingleton sharedInstance] getUserDefaultFranchiseID];
    NSString * path = [NSString stringWithFormat:@"v1/Franchise/%d/Resources?sessionID=%@", [franchiseID intValue], sessionID];
    
    // if resourceTypeID filter is applied, then add it to the endpoint string
    //if (0)
    {
        //path = [NSString stringWithFormat:@"%@&resourceTypeID=%d", path, resourceTypeID];
    }
    
    [httpManager getPath:path parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self endNetworkActivity];
         
         if (operation.responseString)
         {
             NSError *err = nil;
             NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
             
             NSMutableArray *resourcesArray = [[NSMutableArray alloc] init];
             for (NSDictionary *dict in dataDict)
             {
                 [resourcesArray addObject:[APIObjectConversionHelper mapResource:dict withID:franchiseID]];
             }
             
             //NSLog(@"franIndex = %d", franchiseIndex);
             
             [DataStoreSingleton sharedInstance].resourcesList = resourcesArray;
             
             [self sendNotification:@"FetchResourcesListComplete2"];
         }
         else
         {
             NSLog(@"fetchResources failed: %@", operation.responseString);
         }
     }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"fetchResources failed: %@", operation.responseString);
     }];
}

- (void)fetchNotifications
{
    [self startNeworkActivity];
    
    NSString * sessionID = [[UserDefaultsSingleton sharedInstance] getUserSessionID];

    int pageNumber = [[DataStoreSingleton sharedInstance] getCurrentNotificationPageNumber];
    int routeId = 0;
    
    if( [DataStoreSingleton sharedInstance].filterRoute != nil )
    {
        routeId = [[DataStoreSingleton sharedInstance].filterRoute.routeID intValue];
    }

    NSDictionary *userDict = [[UserDefaultsSingleton sharedInstance] getUserObject];
    
    [httpManager setParameterEncoding:AFJSONParameterEncoding];
    
        //User/{userID}/GetDispatches?sessionID={sessionID}&pageID={pageID}&routeID={routeID}
    NSString *path = [NSString stringWithFormat:@"v1/getDispatches?sessionID=%@&pageID=%d&routeID=%d", sessionID, pageNumber + 1, routeId];
    
    [httpManager putPath:path parameters:userDict
                 success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [self endNetworkActivity];
             
             if (operation.responseString)
             {
                 NSError *err = nil;
                 NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:[operation.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                 
                 NSMutableArray *notificationList = [[NSMutableArray alloc] init];
                 for (NSDictionary *dict in dataDict)
                 {
                     Notification *note = [[Notification alloc] initFromDict:dict];
                     [notificationList addObject:note];
                 }
                 
                 [DataStoreSingleton sharedInstance].notificationList = notificationList;
                 
                 if( dataDict.count <= 0 )
                 {
                     [[DataStoreSingleton sharedInstance] decrementCurrentNotificationPageNumber];
                 }
                 
                 [self sendNotification:@"FetchNotificationsComplete"];
             }
             else
             {
                 NSLog(@"fetchNotifications failed: %@", operation.responseString);
             }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
             [self endNetworkActivity];
             
             [self sendNotification:@"FetchNotificationsFailed"];
             
             NSLog(@"fetchNotifications failed: %@", operation.responseString);
        }];
}



@end
