//
//  GroupInMapViewController.m
//  GroupIn
//
//  Created by Zheng Yong on 2/26/14.
//  Copyright (c) 2014 雍 正. All rights reserved.
//

#import "GroupInMapViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface GroupInMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MyAnnotation* annotation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation GroupInMapViewController

@synthesize annotation = _annotation;
@synthesize locationManager = _locationManager;
@synthesize username = _username;
@synthesize password = _password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"] ; // If you use ARC, take out 'autorelease'
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    self.annotation.coordinate = userLocation.location.coordinate;
    NSLog(@"changed location");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    MKMapView *map = [[MKMapView alloc] init];
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D _coordinate = self.locationManager.location.coordinate;
    NSLog(@"%lf, %lf", _coordinate.latitude, _coordinate.longitude);
    MKCoordinateRegion extentsRegion = MKCoordinateRegionMakeWithDistance(_coordinate, 800, 800);
    
    [map setRegion:extentsRegion animated:YES];
    
    self.mapView.delegate = self;
    self.annotation = [[MyAnnotation alloc] initWithCoordinate:_coordinate];
    
    [self.mapView addAnnotation:self.annotation];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
