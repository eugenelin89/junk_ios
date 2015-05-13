//
//  Payment.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-25.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject


@property (nonatomic, strong) NSNumber *paymentID;
@property (nonatomic, strong) NSNumber *taxID;
@property (nonatomic, strong) NSNumber *methodID;
@property (nonatomic, strong) NSNumber *jobID;

@property float paymentAmount;

@property (nonatomic, strong) NSString *paymentName;
@end
