//
//  EditNotesViewController.h
//  GOT-JUNK
//
//  Created by epau on 2/9/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Job;

@interface EditNotesViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) Job *job;
@property (nonatomic, strong) IBOutlet UITextView *notesTextView;

- (id)initWithJob:(Job*)job;

@end
