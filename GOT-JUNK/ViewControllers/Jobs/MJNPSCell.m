//
//  MJNPSCell.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-08.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJNPSCell.h"

@implementation MJNPSCell

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

@end
