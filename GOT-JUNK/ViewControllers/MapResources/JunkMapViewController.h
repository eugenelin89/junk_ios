//
//  JunkMapViewController.h
//  GOT-JUNK
//
//  Created by Mark Pettersson on 2013-06-25.
//  Copyright (c) 2013 1800 Got Junk. All rights reserved.
//

#import "JunkViewController.h"
#import <MapKit/MapKit.h>

@interface JunkMapViewController : JunkViewController <MKMapViewDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet MKMapView * myMapView;
@property (retain, nonatomic) NSMutableArray * jobArray;
@property (retain, nonatomic) MKUserLocation * userLocation;
@property (retain, nonatomic) NSMutableArray * excludedGasStationsList;
@property (retain, nonatomic) NSMutableArray * excludedDisposalStationsList;
@property (retain, nonatomic) NSMutableArray * excludedMiscStationsList;
@property (retain, nonatomic) NSMutableArray * localResourcesList;
@property (retain, nonatomic) NSMutableArray * localPathList;
@property (retain, nonatomic) NSMutableArray * myOverlays;
@property (retain, nonatomic) IBOutlet UIButton * myRouteButton;
@property (retain, nonatomic) IBOutlet UIButton * myJobsButton;
@property (retain, nonatomic) IBOutlet UIButton * myDepotButton;
@property (retain, nonatomic) IBOutlet UIButton * myGasButton;

@property (nonatomic, retain) NSMutableArray * tableList;
@property (nonatomic, retain) NSMutableArray * jobTableList;
@property (nonatomic, retain) NSMutableArray * allSourceTableList;
@property (nonatomic, retain) NSMutableArray * gasSourceTableList;
@property (nonatomic, retain) NSMutableArray * depotSourceTableList;
@property (nonatomic, retain) IBOutlet UITableView * sourceTableView;

@property (retain, nonatomic) NSMutableDictionary * excludedStationsDictionary;
@property (retain, nonatomic) NSMutableDictionary * stationDisplayFlagDictionary;
@property BOOL isUserLocationUpdated;
@property BOOL jobsEnabled;
@property BOOL gasEnabled;
@property BOOL depotEnabled;
@property BOOL miscEnabled;
@property BOOL routeEnabled;

@property (retain, nonatomic) UIAlertView * av;

@property int mappingsRemaining;

@property int loadModeID; // 1 = gas stations, 2 = disposal stations

@property BOOL isShowingGasStations;
@property BOOL isShowingDisposalStations;
@property BOOL isShowingMiscStations;

- (IBAction)jobsButtonPressed:(id)sender;
- (IBAction)gasButtonPressed:(id)sender;
- (IBAction)dumpButtonPressed:(id)sender;
- (IBAction)routeButtonPressed:(id)sender;


@end
