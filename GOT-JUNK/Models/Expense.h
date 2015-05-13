//
//  Expense.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-27.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Expense : NSObject <NSCopying>
@property int expenseID;
@property int routeID;
@property int dayID;
@property (nonatomic, strong) NSString *expenseAccount;
@property int expenseAccountID;
@property (nonatomic, strong) NSString *expense;
@property (nonatomic, strong) NSString *ticket;
@property (nonatomic, strong) NSString *paymentMethod;
@property int paymentMethodID;
@property int taxID;
@property (nonatomic, strong) NSString *tax;
@property int subTotal;
@property int total;
@property (nonatomic, strong) NSString *expenseDescription;
@property (nonatomic, strong) NSString *expenseType;
@property int expenseTypeID;

@end
