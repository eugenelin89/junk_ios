//
//  MJNASADetailsViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-10-24.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"

@interface MJNASADetailsViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITextView* programNotes;
@property (nonatomic, strong) IBOutlet Job * currentJob;

@end
