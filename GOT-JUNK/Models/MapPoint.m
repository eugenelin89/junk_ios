//
//  MapPoint.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-06-25.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "MapPoint.h"
#import <AddressBook/AddressBook.h>

@implementation MapPoint
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate  {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        
    }
    
    return self;
}
-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate andResourceID:(int)resourceId {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        _resourceTypeID = resourceId;
        
    }
    
    return self;
}

-(NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

-(NSString *)phoneNumber
{
    return @"10:00-3:00";
}
-(NSString *)subtitle {
    return _address;
}
-(MKMapItem*)mapItem {
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

- (BOOL)isEqualToMapPoint:(MapPoint *)mapPoint {
    // compare all internal properties
    
    if ((self.resourceTypeID == mapPoint.resourceTypeID) &&
        ([self.type isEqualToString:mapPoint.type]) &&
        ([self.name isEqualToString:mapPoint.name]) &&
        ([self.address isEqualToString:mapPoint.address]) &&
        (self.coordinate.latitude == mapPoint.coordinate.latitude) &&
        (self.coordinate.longitude == mapPoint.coordinate.longitude)) {
        
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)isEqual:(id)object {
    MapPoint * point = (MapPoint *)object;
    
    
    if ([self isKindOfClass:[MKUserLocation class]] || [point isKindOfClass:[MKUserLocation class]]){
        NSLog(@"MKUserLocation detected");
        return NO;
    }
    
    
    if ((self.resourceTypeID == point.resourceTypeID) &&
        ([self.type isEqualToString:point.type]) &&
        ([self.name isEqualToString:point.name]) &&
        ([self.address isEqualToString:point.address]) &&
        (roundf(self.coordinate.latitude) == roundf(point.coordinate.latitude)) &&
        (roundf(self.coordinate.longitude) == roundf(point.coordinate.longitude)) ){
        
        return YES;
        
    } else {
        return NO;
    }
     
    return NO;
}

@end