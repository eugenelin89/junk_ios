//
//  JNExpenseCell.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-27.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "JNExpenseCell.h"

@implementation JNExpenseCell

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

- (IBAction)deleteTapped:(id)sender
{
    
}

@end
