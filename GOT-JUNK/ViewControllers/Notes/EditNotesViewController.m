//
//  EditNotesViewController.m
//  GOT-JUNK
//
//  Created by epau on 2/9/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "EditNotesViewController.h"
#import "Job.h"
#import "FetchHelper.h"
#import "MBProgressHUD.h"

@interface EditNotesViewController ()

@end

@implementation EditNotesViewController

- (id)initWithJob:(Job*)job
{
  self = [super initWithNibName: @"EditNotesViewController" bundle: nil];
  if (self) {
    // Custom initialization
    self.job = job;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoteCompletedSuccessful) name:@"UpdateNoteCompleteSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNoteCompletedFailure) name:@"UpdateNoteCompleteFailure" object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
  }
  return self;
}

- (void)didShowKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    CGRect navFrame = self.navigationController.navigationBar.frame;
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    CGFloat width = CGRectGetWidth(screen);
    CGFloat height = CGRectGetHeight(screen) - navFrame.size.height + navFrame.origin.y - 40 - keyboardFrameBeginRect.size.height;
    
    [self.notesTextView setFrame:CGRectMake(0, navFrame.size.height + navFrame.origin.y, width, height)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Note";

    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.notesTextView.text = @"";
    [self.notesTextView becomeFirstResponder];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveNote)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Callbacks

- (void)saveNote
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    [self.notesTextView resignFirstResponder];
  
    [[FetchHelper sharedInstance] updateNote:self.notesTextView.text forJob:self.job];
  
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateNoteCompletedSuccessful
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self popViewController];
}

- (void)updateNoteCompletedFailure
{
  [MBProgressHUD hideHUDForView:self.view animated:YES];
  
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Update Note Failed" message:@"The note could not be updated by JunkNet" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
  [av show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self popViewController];
}

@end
