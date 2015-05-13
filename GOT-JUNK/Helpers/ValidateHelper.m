//
//  ValidateHelper.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-07.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "ValidateHelper.h"

@implementation ValidateHelper


+ (BOOL) valNumeric:(NSString *)inputString
{
    NSCharacterSet *numericChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    
    NSCharacterSet *charsInAmtField = [NSCharacterSet characterSetWithCharactersInString:inputString];
    
    return [numericChars isSupersetOfSet:charsInAmtField];
}

@end