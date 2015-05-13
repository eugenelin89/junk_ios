//
//  MapPoint.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-06-25.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject <MKAnnotation>
{
    
    NSString *_name;
    NSString *_address;
    CLLocationCoordinate2D _coordinate;

}
@property int resourceTypeID;
@property (nonatomic) NSString * type;
@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(MKMapItem*)mapItem;

- (BOOL)isEqualToMapPoint:(MapPoint *)mapPoint;
- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate andResourceID:(int)resourceId;
//- (BOOL)isEqual:(id)object;
@end