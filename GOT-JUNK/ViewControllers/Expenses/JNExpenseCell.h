//
//  JNExpenseCell.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-27.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JNExpenseCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *accountLabel;
@property (nonatomic, weak) IBOutlet UILabel *amountLabel;

- (IBAction)deleteTapped:(id)sender;


@end
