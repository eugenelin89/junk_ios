//
//  MJEnvironmentalJobDetailsCell.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-09.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJEnvironmentalJobDetailsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel * jobTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel * pickupZipLabel;
@property (nonatomic, strong) IBOutlet UILabel * clientNameLabel;
@property (nonatomic, strong) IBOutlet UILabel * clientCompanyLabel;
@property (nonatomic, strong) IBOutlet UILabel * jobIDLabel;
@property (nonatomic, strong) IBOutlet UILabel * enviroRequiredLabel;
@property (nonatomic, strong) IBOutlet UIImageView * jobTypeIcon;
@property (nonatomic, strong) IBOutlet UIImageView * enviroRequiredIcon;

@end
