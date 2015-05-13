//
//  JunkMapViewController.m
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-06-25.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//


#import "JunkMapViewController.h"
#import "MapPoint.h"
#import "DataStoreSingleton.h"
#import "Job.h"
#import "MFSideMenuContainerViewController.h"
#import "Resource.h"
#import "MBProgressHUD.h"
#import "FetchHelper.h"
#import "Flurry.h"
#import "UserDefaultsSingleton.h"

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface JunkMapViewController ()

@end

@implementation JunkMapViewController

#pragma mark - initializations

- (id)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResourcesList) name:@"FetchResourcesListComplete" object:nil];

    [self setInitialValues];
    
    //Make this controller the delegate for the map view.
    self.myMapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.myMapView setShowsUserLocation:YES];
    if (IS_OS_7_OR_LATER)
    {
        [self.myMapView setShowsBuildings:YES];
        [self.myMapView setShowsPointsOfInterest:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [Flurry logEvent:@"View Resource Map"];

    [self zoomTo];
    
    [self setResourceLists];
}

- (void)setInitialValues
{
    self.title = [NSString stringWithFormat:@"Map (%@)", [[UserDefaultsSingleton sharedInstance] getUserDefaultRouteName] ];
    
    self.isUserLocationUpdated = NO;
    self.isShowingDisposalStations = NO;
    self.isShowingGasStations = NO;
    self.jobsEnabled = NO;
    
    self.myRouteButton.tintColor = [UIColor redColor];
    self.myJobsButton.tintColor = [UIColor redColor];
    self.myDepotButton.tintColor = [UIColor redColor];
    self.myGasButton.tintColor = [UIColor redColor];
}

- (void)setResourceLists
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [self.myMapView removeAnnotations:self.jobTableList];
    [self.myMapView removeAnnotations:self.depotSourceTableList];
    [self.myMapView removeAnnotations:self.gasSourceTableList];

    // Get Jobs
    //
    NSArray *jobsList = [DataStoreSingleton sharedInstance].jobList;
    for (Job *job in jobsList)
    {
        if( job.mapPoint != nil )
        {
            [self.jobTableList addObject:job.mapPoint];
        }
    }
    
    // Get Resources
    //
    NSArray *resourceList = [DataStoreSingleton sharedInstance].resourcesList;
    if ([resourceList count] == 0 && ![[DataStoreSingleton sharedInstance] isOffline])
    {
        [self fetchResourcesList];
    }
    else
    {
        for (Resource* resource in resourceList)
        {
            if (resource.resourceTypeID == 1 && resource.mapPoint != nil )
            {
                [self.gasSourceTableList addObject:resource.mapPoint];
                
            }
            else if (resource.resourceTypeID == 2 && resource.mapPoint != nil )
            {
                [self.depotSourceTableList addObject:resource.mapPoint];
                
            }
        }
    }
    
    [self.sourceTableView reloadData];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}
- (void)fetchResourcesList
{
    [[FetchHelper sharedInstance] fetchResources:0];
}

-(void)zoomTo
{
    float spanX = 0.51725;
    float spanY = 0.51725;
    MKCoordinateRegion region;
    region.center.latitude = self.myMapView.userLocation.coordinate.latitude;
    region.center.longitude = self.myMapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.myMapView setRegion:region animated:YES];
}

-(void)refreshResourcesList
{
    [self setResourceLists];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods.

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (self.routeEnabled)
    {
    NSMutableArray * removalArray = [[NSMutableArray alloc] init];
    //first attempt to remove if in localPathlist
    BOOL neededToRemove = NO;
    
    [self.myMapView removeOverlays:self.myOverlays];

    for (MKPlacemark * thisPlacemark in self.localPathList)
    {
        if ((view.annotation.coordinate.latitude == thisPlacemark.coordinate.latitude) && (view.annotation.coordinate.longitude == thisPlacemark.coordinate.longitude))
        {
            [removalArray addObject:thisPlacemark];
            neededToRemove = YES;
            NSLog(@"Already in here");
        }
    }
    if (neededToRemove)
    {
        [self.localPathList removeObjectsInArray:removalArray];
    }
    else
    {
        CLLocationCoordinate2D sourcePin = self.userLocation.coordinate;
        CLLocationCoordinate2D destinationPin;
        destinationPin = view.annotation.coordinate;
        MKPlacemark * sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourcePin addressDictionary:nil];
        MKPlacemark * sourcePlacemark2 = [[MKPlacemark alloc] initWithCoordinate:destinationPin addressDictionary:nil];
        if ([self.localPathList count] == 0)
            [self.localPathList addObject:sourcePlacemark];
        [self.localPathList addObject:sourcePlacemark2];
      
    }
    for (int i = 0; i <[self.localPathList count]-1; i++)
    {
        CLLocationCoordinate2D newSourcePin = ((MapPoint *)[self.localPathList objectAtIndex:i]).coordinate;
        int j = i+1;
        CLLocationCoordinate2D newDestinationPin = ((MapPoint *)[self.localPathList objectAtIndex:j]).coordinate;
      
            [self plotRouteWithSource:newSourcePin andDestination:newDestinationPin];
    }
    }
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString *annotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        switch (((MapPoint*)annotation).resourceTypeID)
        {
            case 2:
                [pinView setPinColor:MKPinAnnotationColorGreen];
                break;
            
            case 1:
                [pinView setPinColor:MKPinAnnotationColorPurple];
                break;
            
            default:
                [pinView setPinColor:MKPinAnnotationColorRed];
                break;
        }
        
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        UIButton * tempButton = [UIButton buttonWithType:UIButtonTypeCustom];

        UIImage *houseIconView = [UIImage imageNamed:@"Icon.png"];
        tempButton.frame = CGRectMake(20, 100, houseIconView.size.width, houseIconView.size.height);

        [tempButton setImage:houseIconView forState:UIControlStateNormal];
        [tempButton setImage:houseIconView forState:UIControlStateSelected];
        [tempButton setImage:houseIconView forState:UIControlStateHighlighted];

        pinView.leftCalloutAccessoryView = tempButton;
    }
    else
    {
        pinView.annotation = annotation;
    }
    
    return pinView;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.isUserLocationUpdated)
    {
        self.isUserLocationUpdated = YES;
        
        self.userLocation = userLocation;
        [self zoomTo];
    }
}

- (void)mapView2:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MapPoint *location = (MapPoint*)view.annotation;
    NSDictionary *lDict=  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                      forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]];
    
    
    [location.mapItem openInMapsWithLaunchOptions:lDict];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    MapPoint *location = (MapPoint*)view.annotation;
    NSDictionary *lDict=  [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                      forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]];

    [location.mapItem openInMapsWithLaunchOptions:lDict];
}


- (void)plotRouteWithSource:(CLLocationCoordinate2D)sourceCoordinate andDestination:(CLLocationCoordinate2D)destinationCoordinate
{
    MKDirectionsRequest * directionsRequest = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark * sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoordinate addressDictionary:nil];
    MKPlacemark * destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoordinate addressDictionary:nil];
    
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:sourcePlacemark] ];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:destinationPlacemark] ];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKDirections * directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"Error: %@", error.description);
        }
        else
        {
            [self.myOverlays addObject: ((MKRoute *)([response.routes objectAtIndex:0])).polyline];
            [self.myMapView addOverlay:((MKRoute *)([response.routes objectAtIndex:0])).polyline level:MKOverlayLevelAboveRoads];
        }
    }];
}

// get the resources that were NOT chosen by the user
- (NSMutableArray *)getExcludedResourcesOfType:(int)typeID
{
    // a list of gas stations that aren't in the list of chosen map points

    NSMutableArray * otherStationsList = [[NSMutableArray alloc] init];
    
    NSMutableArray * allStationsList;
    switch(typeID)
    {
        case 1:
            allStationsList = self.gasSourceTableList;
            break;
        case 2:
            allStationsList = self.depotSourceTableList;
            break;
        default:
            break;
    }
    
    // go through all the points we're trying to map.
    // if they don't exist in the list of chosen map points, then add to the temp list.
    for (MapPoint * point in allStationsList)
    {
        int indexOfObject = [self.tableList indexOfObject:point];
        if(indexOfObject == NSNotFound){
            [otherStationsList addObject:point];
        }
    }
    
    return otherStationsList;
}
#pragma mark - IBActions

- (IBAction)routeButtonPressed:(id)sender
{
    if (self.routeEnabled)
    {
        self.routeEnabled = NO;
        [self.myMapView removeOverlays:self.myOverlays];
        [self.localPathList removeAllObjects];
        self.myRouteButton.tintColor = [UIColor redColor];
    }
    else
    {
        self.routeEnabled = YES;
        self.myRouteButton.tintColor = [UIColor blueColor];
        
    }
}

- (IBAction)jobsButtonPressed:(id)sender
{
    if ([self.jobTableList count] == 0)
    {
        if (!self.av)
        {
            self.av = [[UIAlertView alloc] initWithTitle:@"Jobs" message:@"There are no jobs to display" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [self.av show];
            return;
        }
    }
    
    if (self.jobsEnabled)
    {
        [self.myMapView removeAnnotations:self.jobTableList];
        self.jobsEnabled = NO;
        self.myJobsButton.tintColor = [UIColor redColor];
    }
    else
    {
        [self.myMapView addAnnotations:self.jobTableList];
        self.myJobsButton.tintColor = [UIColor blueColor];

        self.jobsEnabled = YES;
    }
}

- (IBAction)gasButtonPressed:(id)sender
{
    // Get all the map points that are not already part of the user-selected list
    if ([self.gasSourceTableList count] == 0)
    {
        [self setResourceLists];
        if (!self.av)
        {
            self.av = [[UIAlertView alloc] initWithTitle:@"Having Difficulty Reaching Map Server" message:@"Try waiting some time and using the resource map later" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [self.av show];
        }
    }

    if (self.gasEnabled)
    {
        [self.myMapView removeAnnotations:self.gasSourceTableList];
        self.gasEnabled = NO;
        self.myGasButton.tintColor = [UIColor redColor];

    }
    else
    {
        [self.myMapView addAnnotations:self.gasSourceTableList];
        self.gasEnabled = YES;
        self.myGasButton.tintColor = [UIColor blueColor];
    }
}

- (IBAction)dumpButtonPressed:(id)sender
{
    if ([self.depotSourceTableList count] == 0)
    {
        [self setResourceLists];
        if (!self.av)
        {
            self.av = [[UIAlertView alloc] initWithTitle:@"Having Difficulty Reaching Map Server" message:@"Try waiting some time and using the resource map later" delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [self.av show];
        }
    }
    
    if (self.depotEnabled)
    {
        [self.myMapView removeAnnotations:self.depotSourceTableList];
        self.depotEnabled = NO;
        self.myDepotButton.tintColor = [UIColor redColor];

    }
    else
    {
        [self.myMapView addAnnotations:self.depotSourceTableList];
        self.depotEnabled = YES;
        self.myDepotButton.tintColor = [UIColor blueColor];
    }
}

- (void)toggleResourcePins:(int)tID
{
    NSNumber * typeID = [NSNumber numberWithInt:tID];

    
    // need to lazily instantiate these dictionaries...
    if (!self.excludedStationsDictionary)
    {
        self.excludedStationsDictionary = [[NSMutableDictionary alloc] init];
        
        for (int i=1; i<=3; i++){
        }
    }
    if (!self.stationDisplayFlagDictionary)
    {
        self.stationDisplayFlagDictionary = [[NSMutableDictionary alloc] init];
        
        for (int i=1; i<=3; i++){
            [self.stationDisplayFlagDictionary setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:i]];
        }
    }
    
    NSMutableArray * excludedStationsList;
    
    // for the chosen resource type, get the list of resources that the user did NOT choose
    if (![self.excludedStationsDictionary objectForKey:typeID])
    {
        [self.excludedStationsDictionary setObject:[self getExcludedResourcesOfType:[typeID intValue]] forKey:typeID];
    }
    
    excludedStationsList = [self.excludedStationsDictionary objectForKey:typeID];
    
    // toggle the display of the pins
    if ([self.stationDisplayFlagDictionary objectForKey:typeID] == [NSNumber numberWithBool:1])
    {
        [self.myMapView removeAnnotations:[self.excludedStationsDictionary objectForKey:typeID]];
    }
    else
    {
        [self.myMapView addAnnotations:[self.excludedStationsDictionary objectForKey:typeID]];
    }
    
    NSNumber * b = [self.stationDisplayFlagDictionary objectForKey:typeID];
    b = [NSNumber numberWithBool:(![b boolValue])];
    
    // toggle the flag indicating whether or not the resources of the chosen type are being displayed
    [self.stationDisplayFlagDictionary setObject:b forKey:typeID];
    
}

- (void)showDirections:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.myMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.av = nil;
}


#pragma mark - Lazy Instantiations

- (NSMutableArray *)myOverlays
{
    if (!_myOverlays){
        _myOverlays = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return _myOverlays;
}

- (NSMutableArray *)localResourcesList
{
    if (!_localResourcesList){
        _localResourcesList = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return _localResourcesList;
}
- (NSMutableArray *)localPathList
{
    if (!_localPathList){
        _localPathList = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return _localPathList;
}

#pragma mark - Lazy Instantiated
- (NSMutableArray *)jobTableList
{
    if (!_jobTableList){
        _jobTableList = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return _jobTableList;
}
- (NSMutableArray *)allSourceTableList
{
    if (!_allSourceTableList){
        _allSourceTableList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _allSourceTableList;
}
- (NSMutableArray *)tableList
{
    if (!_tableList){
        _tableList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _tableList;
}
- (NSMutableArray *)gasSourceTableList
{
    if (!_gasSourceTableList){
        _gasSourceTableList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _gasSourceTableList;
}

- (NSMutableArray *)depotSourceTableList
{
    if (!_depotSourceTableList){
        _depotSourceTableList = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _depotSourceTableList;
}

@end
