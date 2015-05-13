//
//  EditContactViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Job;

@interface EditContactViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>


@property (strong) IBOutlet UIView *containerView;
@property (strong) IBOutlet UITextField *emailtextField;
@property (strong) IBOutlet UILabel *nameLabel;
@property (strong) Job *job;

- (id)initWithJob:(Job*)job;

@end
