//
//  PhoneEditCell.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-03.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "PhoneEditCell.h"

@implementation PhoneEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //  [textField2 setText:[textField1.text stringByReplacingCharactersInRange:range withString:string]];
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    
    if ([string isEqualToString:@""]) return NO;
    unichar c = [string characterAtIndex:0];
    if (([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c]))
    {
        NSString * discountNumber = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSScanner *scanner = [NSScanner scannerWithString:discountNumber];
        NSCharacterSet *zeros = [NSCharacterSet
                                 characterSetWithCharactersInString:@"0"];
        [scanner scanCharactersFromSet:zeros intoString:NULL];
        
        // Get the rest ofthe string and log it
        discountNumber = [discountNumber substringFromIndex:[scanner scanLocation]];
        if ([discountNumber length] > 4)
            
        {
            NSString * cents=[discountNumber substringFromIndex:MAX((int)[discountNumber length]-4, 0)];
            NSString * dollars=[discountNumber substringToIndex:[discountNumber length]-4];
            [textField setText:[NSString stringWithFormat:@"%@-%@",dollars,cents]];
            
        }
        
        return NO;
    } else {
        return NO;
    }
}

@end
