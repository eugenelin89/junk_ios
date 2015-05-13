//
//  MJEnvironmentalDetailViewController.h
//  Example
//
//  Created by Mark Pettersson on 2013-07-25.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MJTemplateViewController.h"
#import "Job.h"
#import "Enviro.h"
#import "EnviroDestination.h"
#import "JunkType.h"

@interface MJEnvironmentalDetailViewController : UIViewController <UIPickerViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIView * subView;
@property (nonatomic, strong) IBOutlet UITableView * tableView;

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPickerView* pickerView;

@property (nonatomic, retain) IBOutlet UIButton * chooseJunkTypeButton;
@property (nonatomic, retain) IBOutlet UILabel * junkTypeLabel;

@property (nonatomic, retain) IBOutlet UIButton * chooseAccountButton;
@property (nonatomic, retain) IBOutlet UILabel * accountLabel;

//@property (nonatomic, retain) IBOutlet UISlider* percentageSlider;
//@property (nonatomic, retain) IBOutlet UILabel* percentage;
@property (nonatomic, retain) IBOutlet UITextField * diversionTextField;

@property (nonatomic, retain) IBOutlet UITextField * weightTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl * weightTypeSegment;

@property (nonatomic, strong) Enviro * enviro;
@property (nonatomic, strong) Job * job;
@property (nonatomic, strong) EnviroDestination *enviroDestination;
@property (nonatomic, strong) JunkType * junkType;
@property (nonatomic, strong) NSArray * loadPointsArray;

- (IBAction) diversionInputFinished:(UITextField *)sender;
- (IBAction) weightInputFinished:(id)sender;
- (IBAction) chooseJunkType:(UIButton *)sender;
- (IBAction) chooseAccount:(UIButton *)sender;
- (IBAction) changeWeightType:(UISegmentedControl *)sender;

@end
