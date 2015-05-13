//
//  MJNotificationCell.h

//  GOT-JUNK
//
//  Created by David Block on 2015-04-08.
//  Copyright (c) 2015 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJNotificationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailView;
@property (weak, nonatomic) IBOutlet UIImageView *acceptedImage;
@property (weak, nonatomic) IBOutlet UIView *borderView;

@end
