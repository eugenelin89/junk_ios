//
//  ExpensePaymentMethod.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-09-26.
//  Copyright (c) 2013 Gargoyle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExpensePaymentMethod : NSObject

@property int paymentMethodID;
@property (nonatomic, strong) NSString * paymentMethodName;

@end
