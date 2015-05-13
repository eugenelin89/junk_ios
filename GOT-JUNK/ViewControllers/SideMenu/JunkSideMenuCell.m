//
//  JunkSideMenuCell.m
//  MFSideMenuDemoBasic
//
//  Created by Mark Pettersson on 2013-07-05.
//  Copyright (c) 2013 University of Wisconsin - Madison. All rights reserved.
//

#import "JunkSideMenuCell.h"

@implementation JunkSideMenuCell

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
-(void)setImage2:(UIImage *)image
{
  //  self.imageView.image = image;
  //  [self.imageView setImage:image];
    [self.cellImage setImage:image];
   // self.imageView.image.re
}
@end
