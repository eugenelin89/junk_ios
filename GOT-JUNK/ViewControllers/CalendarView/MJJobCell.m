//
//  MJJobCell.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-08-23.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MJJobCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"
#import "UserDefaultsSingleton.h"

@implementation MJJobCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:3.0];
        [self.backGround.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        

    }
    return self;
}

- (void)setJob:(Job *)job
{
    _job = job;

    self.name.text = [NSString stringWithFormat:@"%@", job.clientName];
    self.time.text = [NSString stringWithFormat:@"%@ - %@", job.jobStartTime, job.jobEndTime];
    self.jobID.text = [NSString stringWithFormat:@"%@", job.jobID];
    if ([job.pickupCompany length] > 1)
        self.companyName.text = job.pickupCompany;
    else
        self.companyName.text = job.clientCompany;

    self.zipCode.text = job.zipCode;
    if ([job.programNotes length] > 1)
    {
        self.specialLabel.hidden = NO;
    }
    else
    {
        self.specialLabel.hidden = YES;
    }
    if (job.isEnviroRequired ==  YES)
        self.enviroImage.hidden = NO;
    else
        self.enviroImage.hidden = YES;
    if ([job.jobType intValue] == 3)
    {
        self.name.text = @"Bookoff";
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:1.0];
        [self.backGround.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.backGround.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
        UIImage *image = [UIImage imageNamed: @"icon-hourglass.png"];
        self.jobTypeImage.image= image;
        self.phoneStatusImage.hidden = YES;

    }
    else
    {
        self.phoneStatusImage.hidden = NO;
    }
    if ([job.clientTypeID intValue] == 2)
    {
        if ([job.total integerValue] > 0)
        {
        UIImage *image = [UIImage imageNamed: @"commercialChecked.png"];
        self.jobTypeImage.image= image;
        }
        else
        {
            UIImage *image = [UIImage imageNamed: @"commercial.png"];
            self.jobTypeImage.image= image;
        }
    }
    if ([job.clientTypeID intValue] == 1)
    {
        if ([job.junkCharge integerValue] > 0)
        {
            UIImage *image = [UIImage imageNamed: @"residentialChecked.png"];
            self.jobTypeImage.image= image;
        }
        else
        {        UIImage *image = [UIImage imageNamed: @"houseUnChecked.png"];
            self.jobTypeImage.image= image;
            
        }
    }
    if ([job.jobType intValue] == 2)
    {
        UIImage *image = [UIImage imageNamed: @"icon-clipboard.png"];
        self.jobTypeImage.image=image;//  [[UIImageView alloc] initWithImage: image];
        
    }
    if ([job.callAheadStatus isEqualToString:@"Incomplete"])
    {
        UIImage *image = [UIImage imageNamed: @"notphoned_white.png"];

        self.phoneStatusImage.image=image;
    }
    else
    {
        UIImage *image = [UIImage imageNamed: @"phoned_white.png"];

        self.phoneStatusImage.image=image;
    }
    if ([self.job.junkCharge integerValue] < 10)
    {
        self.jobComplete.text = @"Not Complete";
    }
    else
    {
        self.jobComplete.text = [NSString stringWithFormat:@"$%@", self.job.junkCharge];
    }
    NSString *colorString = [NSString stringWithFormat:@"0x%@", job.zoneColor];
    NSString *colorFontString = [NSString stringWithFormat:@"0x%@", job.zoneFontColor];

    colorString = [colorString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    colorFontString = [colorFontString stringByReplacingOccurrencesOfString:@"#" withString:@""];

    UserDefaultsSingleton *defaults = [UserDefaultsSingleton sharedInstance];
    if (![defaults getUserColorPref])
    {
        colorString = @"0x8CC449";
        colorFontString = @"0x000000";
    }
    UIColor *col2 = [UIColor colorWithHexString:colorString andAlpha:1.0];
    UIColor *fontColor = [UIColor colorWithHexString:colorFontString andAlpha:1.0];
    [self.name setTextColor:fontColor];
    [self.time setTextColor:fontColor];
    [self.jobID setTextColor:fontColor];
    [self.jobComplete setTextColor:fontColor];
    [self.specialLabel setTextColor:fontColor];
    [self.zipCode setTextColor:fontColor];
    [self.companyName setTextColor:fontColor];
    if ([_job.jobType intValue] == 3)
    {
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:1.0];
        [self.backGround.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.backGround.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    }
    else
    {
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:1.0];
        [self.backGround.layer setBorderColor:col2.CGColor];
        [self.backGround.layer setBackgroundColor:col2.CGColor];
    }
   
    [self setNeedsDisplay]; // force drawRect:

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.layer setCornerRadius:10.0];
    if ([_job.jobType intValue] == 3)
    {
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:1.0];
        [self.backGround.layer setBorderColor:[UIColor grayColor].CGColor];
        [self.backGround.layer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    }
    else
    {
        [self.backGround.layer setCornerRadius:10.0];
        [self.backGround.layer setBorderWidth:1.0];
      //  [self.backGround.layer setBorderColor:[UIColor greenColor].CGColor];
    }
    [self setNeedsDisplay];
    //[self.backGround.layer setBorderColor:[UIColor greenColor].CGColor];
    if (self.isSelected)
    {
        if (self.isRed)
        {
            [self.backGround.layer setBackgroundColor:[UIColor colorWithRed:255/255.0f green:17/255.0f blue:25/255.0f alpha:1.0f]
.CGColor];
            [self.backGround.layer setBorderColor:[UIColor colorWithRed:255/255.0f green:17/255.0f blue:25/255.0f alpha:1.0f]
.CGColor];
        }
        else
        {
            [self.backGround.layer setBackgroundColor:[UIColor colorWithRed:15/255.0f green:162/255.0f blue:248/255.0f alpha:1.0f].CGColor];
            [self.backGround.layer setBorderColor:[UIColor colorWithRed:15/255.0f green:162/255.0f blue:248/255.0f alpha:1.0f].CGColor];
            
        }
        self.layer.zPosition = 10000.0;
        [self.layer setZPosition:10000.0];
    }
    
}


@end
