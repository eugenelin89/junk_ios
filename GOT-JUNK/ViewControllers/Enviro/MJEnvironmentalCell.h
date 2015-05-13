//
//  MJEnvironmentalCell.h
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-10-08.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJEnvironmentalCell : UITableViewCell
@property int environmentID;
@property (nonatomic, strong) IBOutlet UILabel * junkType;
@property (nonatomic, strong) IBOutlet UILabel * truckLoads;
@property (nonatomic, strong) IBOutlet UILabel * diversion;
@property (nonatomic, strong) IBOutlet UILabel * destination;

@end
