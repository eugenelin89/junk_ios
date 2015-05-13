//
//  AddNoteViewController.m
//  GOT-JUNK
//
//  Created by epau on 1/23/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "NotesViewController.h"
#import "Job.h"
#import "EditNotesViewController.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

@synthesize notesTextView = _notesTextView;

- (id)initWithJob:(Job*)job
{
  self = [super initWithNibName: @"NotesViewController" bundle: nil];
  if (self) {
    // Custom initialization
    self.currentJob = job;
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Notes";

    CGRect navFrame = self.navigationController.navigationBar.frame;
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGFloat width = CGRectGetWidth(screen);
    CGFloat height = CGRectGetHeight(screen) - navFrame.size.height + navFrame.origin.y - 30;
    
    [self.notesTextView setFrame:CGRectMake(0, navFrame.size.height + navFrame.origin.y, width, height)];
    
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.notesTextView.text = self.currentJob.jobComments;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightSideMenuButtonPressed:)];
}

- (void)rightSideMenuButtonPressed:(id)sender
{
    EditNotesViewController *vc = [[EditNotesViewController alloc] initWithJob:self.currentJob];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
