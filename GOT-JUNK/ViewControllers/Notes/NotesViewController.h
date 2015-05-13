//
//  AddNoteViewController.h
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Job;

@interface NotesViewController : UIViewController

@property (nonatomic, strong) Job *currentJob;
@property (nonatomic, strong) IBOutlet UITextView *notesTextView;

- (id)initWithJob:(Job*)job;

@end
