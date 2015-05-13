//
//  APIObjectConversionHelper.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-19.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "APIObjectConversionHelper.h"
#import "APIDataConversionHelper.h"

@implementation APIObjectConversionHelper

+ (LoadTypeSize *)mapLoadTypeSize:(NSDictionary *)dict;
{
    LoadTypeSize * loadTypeSize = [[LoadTypeSize alloc] init];
    loadTypeSize.loadTypeSizeID = [[dict objectForKey:@"itemID"] integerValue];
    loadTypeSize.loadTypeSize = [dict objectForKey:@"itemName"];
    loadTypeSize.loadTypeID = [[dict objectForKey:@"countryID"] integerValue];
    loadTypeSize.percentOfTruck = [[dict objectForKey:@"diversionPercent"] floatValue];
    
    if( [loadTypeSize.loadTypeSize isKindOfClass:[NSString class]] == NO )
    {
        loadTypeSize.loadTypeSize = @"";
    }
    
    return loadTypeSize;
}
+ (Expense *)mapExpense:(NSDictionary *)dict
{
    Expense *expense = [[Expense alloc] init];
    expense.expenseID = [[dict objectForKey:@"expenseID"] integerValue];
    expense.routeID = [[dict objectForKey:@"routeID"] integerValue];
    expense.dayID = [[dict objectForKey:@"dayID"] integerValue];
    expense.expenseAccountID = [[dict objectForKey:@"accountID"] integerValue];
    expense.expenseAccount = [dict objectForKey:@"account"];
    expense.expenseTypeID = [[dict objectForKey:@"expenseTypeID"] integerValue];
    expense.expenseType = [dict objectForKey:@"expenseType"];
    expense.ticket = [dict objectForKey:@"ticket"];
    expense.paymentMethodID = [[dict objectForKey:@"paymentMethodID"] integerValue];
    expense.paymentMethod = [dict objectForKey:@"paymentMethod"];
    expense.subTotal = [[dict objectForKey:@"subTotal"] integerValue];
    expense.taxID = [[dict objectForKey:@"taxID"] integerValue];
    expense.tax = [NSString stringWithFormat:@"%0.02f", [[dict objectForKey:@"tax"] floatValue]];
    expense.total = [[dict objectForKey:@"total"] integerValue];
    expense.expenseDescription = [dict objectForKey:@"description"];
    
    if( [expense.expenseAccount isKindOfClass:[NSString class]] == NO )
    {
        expense.expenseAccount = @"";
    }
    
    if( [expense.expenseType isKindOfClass:[NSString class]] == NO )
    {
        expense.expenseType = @"";
    }
    
    if( [expense.ticket isKindOfClass:[NSString class]] == NO )
    {
        expense.ticket = @"";
    }
    
    if( [expense.expenseDescription isKindOfClass:[NSString class]] == NO )
    {
        expense.expenseDescription = @"";
    }
    
    
    return expense;
}

+ (Resource *)mapResource:(NSDictionary*)dict withID:(NSNumber*)franId;
{
    Resource *resource = [[Resource alloc] init];
    resource.resourceID = [[dict objectForKey:@"resourceID"] intValue];
    resource.resourceName = [dict objectForKey:@"resourceName"];
    resource.latitude = [APIDataConversionHelper convertCoordinateDataForRetrieval:[[dict objectForKey:@"latitude"] intValue]];
    resource.longitude = [APIDataConversionHelper convertCoordinateDataForRetrieval:[[dict objectForKey:@"longitude"] intValue]];
    resource.resourceTypeID = [[dict objectForKey:@"resourceTypeID"] intValue];
    resource.resourceType = [dict objectForKey:@"resourceType"];
    resource.city = [dict objectForKey:@"city"];
    resource.country = [dict objectForKey:@"country"];
    resource.state = [dict objectForKey:@"state"];
    resource.street = [dict objectForKey:@"street"];
    resource.zipcode = [dict objectForKey:@"zipcode"];
    
    if( [resource.resourceName isKindOfClass:[NSString class]] == NO )
    {
        resource.resourceType = @"";
    }
    
    if( [resource.resourceType isKindOfClass:[NSString class]] == NO )
    {
        resource.resourceType = @"";
    }

    if( [resource.city isKindOfClass:[NSString class]] == NO )
    {
        resource.city = @"";
    }
    
    if( [resource.country isKindOfClass:[NSString class]] == NO )
    {
        resource.country = @"";
        NSLog(@"FranchiseID = %d, ResourceID = %d", [franId intValue], resource.resourceID);
    }
    
    if( [resource.state isKindOfClass:[NSString class]] == NO )
    {
        resource.state = @"";
    }
    
    if( [resource.street isKindOfClass:[NSString class]] == NO )
    {
        resource.street = @"";
    }
    
    if( [resource.zipcode isKindOfClass:[NSString class]] == NO )
    {
        resource.zipcode = @"";
    }
    
    return resource;
}

@end
