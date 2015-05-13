//
//  MJJobCell.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
@interface MJJobCell : UICollectionViewCell
@property(nonatomic, weak) IBOutlet UIView *backGround;
@property(nonatomic, weak) IBOutlet UILabel *name;
@property(nonatomic, weak) IBOutlet UILabel *time;
@property(nonatomic, weak) IBOutlet UILabel *jobID;
@property(nonatomic, weak) IBOutlet UILabel *jobComplete;
@property(nonatomic, weak) IBOutlet UILabel *specialLabel;

@property(nonatomic, weak) IBOutlet UILabel *zipCode;
@property(nonatomic, weak) IBOutlet UILabel *companyName;
@property(nonatomic, strong) IBOutlet UIImageView *jobTypeImage;
@property(nonatomic, strong) IBOutlet UIImageView *phoneStatusImage;
@property(nonatomic, strong) IBOutlet UIImageView *enviroImage;

@property (nonatomic, weak) Job *job;
@property BOOL isSelected;
@property BOOL isRed;

@end
