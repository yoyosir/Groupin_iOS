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
#import "GroupChatViewController.h"

@interface GroupInMapViewController () <MKMapViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MyAnnotation* annotation;
@property (strong, nonatomic) NSMutableArray *groups;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString* groupname;
@property (nonatomic, strong) NSString* passcode;
@property (nonatomic, strong) NSData* rawData;
@end

@implementation GroupInMapViewController

@synthesize annotation = _annotation;
@synthesize locationManager = _locationManager;
@synthesize username = _username;
@synthesize password = _password;
@synthesize groups = _groups;
@synthesize groupname = _groupname;
@synthesize passcode = _passcode;
@synthesize rawData = _rawData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"OK button!");
        self.passcode = [alertView textFieldAtIndex:0].text;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/joingroup"]];
        NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
        [dic setValue:self.username forKey:@"username"];
        [dic setValue:self.password forKey:@"password"];
        [dic setValue:self.groupname forKey:@"groupname"];
        [dic setValue:self.passcode forKey:@"passcode"];
        NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        [request setHTTPMethod:@"POST"];
        NSHTTPURLResponse* urlResponse = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
        NSString *responseString = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"join group:%@", responseString);
        if ([responseString isEqualToString:@"invalid passcode"] || [responseString isEqualToString:@"denied"])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Denied" message:responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/retrievemessage"]];
            NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
            [dic setValue:self.username forKey:@"username"];
            [dic setValue:self.password forKey:@"password"];
            [dic setValue:self.groupname forKey:@"groupname"];
            [dic setValue:self.passcode forKey:@"passcode"];
            NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"POST"];
            NSHTTPURLResponse* urlResponse = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
            self.rawData = responseData;
            [self performSegueWithIdentifier:@"mapToChat" sender:self];
        }
    }
}

- (void)enterGroup:(NSString*)groupname
{
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Passcode" message:@"Enter passcode:" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"OK", nil];
    self.groupname = groupname;
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [alertView show];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self enterGroup:[view.annotation title]];
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    if (annotation == self.annotation)
    {
        pin.draggable = YES;
        pin.canShowCallout = NO;
        pin.pinColor = MKPinAnnotationColorGreen;

    }
    else
    {
        pin.draggable = NO;
        pin.canShowCallout = YES;
        pin.pinColor = MKPinAnnotationColorPurple;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        pin.rightCalloutAccessoryView = button;
    }
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
        [self updateGroupInfoWithLocation:droppedAt];
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    //self.annotation.coordinate = userLocation.location.coordinate;
    //NSLog(@"changed location");
}

- (void)updateGroupInfoWithLocation:(CLLocationCoordinate2D)_coordinate
{
    MKMapView *map = [[MKMapView alloc] init];
    MKCoordinateRegion extentsRegion = MKCoordinateRegionMakeWithDistance(_coordinate, 800, 800);
    [map setRegion:extentsRegion animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://groupintemp.appspot.com/groupin/searchgroup"]];
    NSMutableDictionary *dic  = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:self.password forKey:@"password"];
    [dic setValue:[NSString stringWithFormat:@"%lf", _coordinate.latitude] forKeyPath:@"latitude"];
    [dic setValue:[NSString stringWithFormat:@"%lf", _coordinate.longitude] forKeyPath:@"longitude"];
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    self.groups = [[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    NSLog(@"%@", [[NSString alloc] initWithData:responseData encoding:4]);
    [self.mapView removeAnnotations:[self.mapView annotations]];
    self.annotation =  [[MyAnnotation alloc] initWithCoordinate:_coordinate];
    self.annotation.draggable = YES;
    [self.mapView addAnnotation:self.annotation];
    for (NSDictionary* dic in self.groups)
    {
        CLLocationCoordinate2D groupCoor;
        groupCoor.latitude = [[dic valueForKey:@"latitude"] doubleValue];
        groupCoor.longitude = [[dic valueForKey:@"longitude"] doubleValue];
        MyAnnotation* myAnnotation = [[MyAnnotation alloc] initWithCoordinate:groupCoor];
        myAnnotation.title = [dic valueForKey:@"groupname"];
        myAnnotation.draggable = NO;
        [self.mapView addAnnotation:myAnnotation];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.mapView.delegate = self;
    MKCoordinateRegion region;
    region.center = self.locationManager.location.coordinate;
    region.span.latitudeDelta = 0.02;
    region.span.longitudeDelta = 0.015;
    self.mapView.region = region;
    
    [self updateGroupInfoWithLocation:self.locationManager.location.coordinate];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setRawData:self.rawData user:self.username password:self.password group:self.groupname passcode:self.passcode];
}

@end
