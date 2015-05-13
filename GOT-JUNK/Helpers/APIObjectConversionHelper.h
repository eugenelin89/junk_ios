//
//  APIObjectConversionHelper.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-19.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "Expense.h"
#import "LoadTypeSize.h"
@interface APIObjectConversionHelper : NSObject

+ (LoadTypeSize *)mapLoadTypeSize:(NSDictionary *)dict;
+ (Expense *)mapExpense:(NSDictionary *)dict;
+ (Resource *)mapResource:(NSDictionary*)dict withID:(NSNumber*)franId;


@end
