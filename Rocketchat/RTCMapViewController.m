//
//  RTCMapViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 31/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <MapKit/MapKit.h>


#import "RTCMapViewController.h"
#import "RTCMainViewController.h"

#import "RTCMediaStore.h"
#import "RTCMessageCollectionViewLayout.h"

#import "UIImage+Scale.h"


@interface RTCMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) BOOL isGotLocation;
@property (nonatomic) BOOL didShowLocation;

@property (strong, nonatomic) UIImage *snapshot;

@property (strong, nonatomic) NSTimer *t;
@property (strong, nonatomic) MKMapSnapshotter *snapshotter;

@property (nonatomic) BOOL isForSendingLocation;

@end

@implementation RTCMapViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForSendingLocation" userInfo:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForSendingLocation" userInfo:nil];
}

- (instancetype)initForSendingLocation:(BOOL)isForSending {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.isForSendingLocation = isForSending;
        
        [self setupNavigationForSending:isForSending];
        
        if (isForSending) {
            [self setupLocation];
        }
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isForSendingLocation) {
        [self setupMapView];
    } else {
        if (self.sentLocation) {
            [self moveMapToLocation:self.sentLocation];
            [self addSentLocationAnnotation];
        }
    }
}

- (void)dealloc {
    NSLog(@"Dealloc");
}

#pragma mark - Setup

- (void)setupNavigationForSending:(BOOL)isForSending {
    self.navigationItem.title = @"Карта";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeButtonPressed:)];
    
    if (isForSending) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)setupLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)setupMapView {
    self.mapView.delegate = self;
    
    self.isGotLocation = NO;
    self.didShowLocation = NO;
    
    self.mapView.showsUserLocation = YES;
}

#pragma mark - Bar Buttons Actions

- (void)closeButtonPressed:(id)sender {
    [self closeItself];
}

- (void)doneButtonPressed:(id)sender {
    
    [self addSnapshot];

}

#pragma mark - Close 

- (void)closeItself {
    if (self.isForSendingLocation) {
        [self.t invalidate];
        [self.locationManager stopUpdatingLocation];
        [self.snapshotter cancel];
        self.snapshotter = nil;
        
        [self.mvc dismissViewControllerAnimated:YES completion:^{
            [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
        }];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Adding Pin Location

- (void)addSentLocationAnnotation {
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:self.sentLocation.coordinate];
    [annotation setTitle:@"Я был тут"];
    [self.mapView addAnnotation:annotation];
    
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    CLLocation *newLocation = [locations lastObject];
    
    if (newLocation && !self.isGotLocation) {
        self.isGotLocation = YES;
        [self moveMapToLocation:newLocation];
    }
    
}

- (void)moveMapToLocation:(CLLocation *)location {
    
    if (location) {
        [self.mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.000001, 0.000001)) animated:NO];
    }
    
}

#pragma mark - Map View Delegate 

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.didShowLocation = YES;
}

#pragma mark - Snapshot


- (void)takeSnapshotOnTimer:(NSTimer *)t {
    NSLog(@"timer!");
    if (self.didShowLocation) {

        [self snapshotImage];
        
        if (!self.snapshotter.loading) {
            [t invalidate];
       //     self.t = nil;
            [self addSnapshot];
        }
       

        
    }
}

- (void)addSnapshot {
    
    if (self.snapshot) {
        NSLog(@"adding snapshot from add Snapshot");
        [[RTCMediaStore sharedStore] addLocationSnapshotWithImage:self.snapshot andLocation:self.locationManager.location];
        
        [self closeItself];
        
    } else {
        if (!self.t) {
            self.t = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(takeSnapshotOnTimer:) userInfo:nil repeats:YES];
        }
    }
    
}

- (void)snapshotImage {
    if (self.snapshotter) return;
    
    [self moveMapToLocation:self.locationManager.location];
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(280, 280); // такс такс
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    self.snapshotter = snapshotter;
    
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        UIImage *image = snapshot.image;
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        UIImage *pinImage = [UIImage imageNamed:@"locationIcon"];//pin.image;
        
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        
        for (id<MKAnnotation>annotation in self.mapView.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) {
                
                point.x = point.x - [pinImage size].width / 2.0;
                point.y = point.y - [pinImage size].height / 2.0;
                
                [pinImage drawAtPoint:point];
            }
        }
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        
        self.snapshot = finalImage;
        
        
    }];
    
}

@end
