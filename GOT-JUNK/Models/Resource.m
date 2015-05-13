//
//  Resource.m
//  GOT-JUNK
//
//  Created by Thomas Chuah on 2013-12-11.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "Resource.h"
#import "Flurry.h"

@implementation Resource

- (BOOL)isEqual:(id)object
{
    Resource * res = (Resource *)object;
    
    if (res){
        if ((res.resourceID == self.resourceID) &&
            ([self.resourceName isEqualToString:res.resourceName]) &&
            (self.resourceTypeID == res.resourceTypeID) &&
            (self.latitude = res.latitude) &&
            (self.longitude == res.longitude) &&
            ([self.city isEqualToString:res.city]) &&
            ([self.country isEqualToString:res.country]) &&
            ([self.state isEqualToString:res.state]) &&
            ([self.street isEqualToString:res.street]) &&
            ([self.zipcode isEqualToString:res.zipcode]))
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getAddress
{
    @try
    {
        if( [self.country isKindOfClass:[NSString class]] == NO ) //   == [NSNull null] )
        {
            self.country = @"";
        }
        
        
        if( self.zipcode != nil )
        {
            return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", self.street, self.city, self.state, self.country, self.zipcode];
        }
        else
        {
            return [NSString stringWithFormat:@"%@, %@, %@, %@", self.street, self.city, self.state, [self.country stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    @catch (NSException* exception)
    {
        NSString *error = [NSString stringWithFormat:@"%@ - Stack: %@", exception.description, [exception callStackSymbols] ];
        
        [Flurry logError:@"ERROR_007" message:error exception:exception];
    }
}

@end
