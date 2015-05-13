//
//  PaymentMethod.h
//  GOT-JUNK
//
//  Created by epau on 2/8/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentMethod : NSObject

@property (nonatomic, strong) NSNumber *paymentID;
@property (nonatomic, strong) NSString *paymentName;

@end
