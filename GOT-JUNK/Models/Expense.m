//
//  Expense.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-27.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "Expense.h"

@implementation Expense

- (id)copyWithZone:(NSZone *)zone
{
    Expense * another = [[Expense alloc] init];
    another.expenseID = self.expenseID;
    another.routeID = self.routeID;
    another.dayID = self.dayID;
    another.expenseAccount = self.expenseAccount;
    another.expenseAccountID = self.expenseAccountID;
    another.expense = self.expense;
    another.ticket = self.ticket;
    another.paymentMethod = self.paymentMethod;
    another.paymentMethodID = self.paymentMethodID;
    another.taxID = self.taxID;
    another.tax = self.tax;
    another.subTotal = self.subTotal;
    another.total = self.total;
    another.expenseDescription = self.expenseDescription;
    another.expenseType = self.expenseType;
    another.expenseTypeID = self.expenseTypeID;
    
    return another;
}

@end
