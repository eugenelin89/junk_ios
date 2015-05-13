//
//  PhoneEditCell.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-03.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneEditCell : UITableViewCell  <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *areaField;
@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UITextField *extField;


@end
