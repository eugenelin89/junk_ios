//
//  main.m
//  GOT-JUNK
//
//  Created by David Young-Chan Kay on 1/22/13.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flurry.h"
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    int ret = -1;
    @autoreleasepool
    {
        @try
        {
             ret = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException* exception)
        {
            NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
            
            [Flurry logError:@"MAIN_ERROR" message:error exception:exception];

            NSLog(@"Uncaught exception: %@", exception.description);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        }
    }
    
    return ret;
}
