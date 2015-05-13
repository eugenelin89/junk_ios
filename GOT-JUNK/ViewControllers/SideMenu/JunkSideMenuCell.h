//
//  JunkSideMenuCell.h
//  MFSideMenuDemoBasic
//
//  Created by Mark Pettersson on 2013-07-05.
//  Copyright (c) 2013 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JunkSideMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *cellImage;
-(void)setImage2:(UIImage *)image;

@end
