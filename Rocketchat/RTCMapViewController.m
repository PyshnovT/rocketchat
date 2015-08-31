//
//  RTCMapViewController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 31/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMapViewController.h"
#import "RTCMainViewController.h"
#import "RTCMediaStore.h"
#import "RTCMessageCollectionViewLayout.h"
#import "UIImage+Scale.h"

#import <MapKit/MapKit.h>

@interface RTCMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic) BOOL isGotLocation;
@property (nonatomic) BOOL didShowLocation;
@property (nonatomic) BOOL didEndRenderingMap;

@property (strong, nonatomic) UIImage *snapshot;

@property (strong, nonatomic) NSTimer *t;

@end

@implementation RTCMapViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self setupNavigation];
        
        [self setupLocation];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMapView];
   //
}

- (void)dealloc {
    NSLog(@"Dealloc");
}

- (void)setupNavigation {
    self.navigationItem.title = @"Карта";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
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
    
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.userInteractionEnabled = NO;
    
    self.isGotLocation = NO;
    self.didEndRenderingMap = NO;
    self.didShowLocation = NO;
    
    self.mapView.showsUserLocation = YES;
}

#pragma mark - Bar Buttons Actions

- (void)closeButtonPressed:(id)sender {

    [self closeItself];
}

- (void)doneButtonPressed:(id)sender {
    
    [self takeSnapshotWithCompletion:^{
        [self closeItself];
    }];
    

}

#pragma mark - Close 

- (void)closeItself {
    [self.t invalidate];
    [self.locationManager stopUpdatingLocation];
    
    [self.mvc dismissViewControllerAnimated:YES completion:^{
        [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
    }];
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

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView {
    NSLog(@"Will start");
    self.didEndRenderingMap = NO;
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
        NSLog(@"did finish");
    self.didEndRenderingMap = YES;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
        NSLog(@"Got location");
    self.didShowLocation = YES;
}

#pragma mark - Snapshot
/*
- (UIImage *)snapshotImage {

    //UIGraphicsBeginImageContextWithOptions(wholeRect.size, YES, [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(self.mapView.frame.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width));
    [self.view.layer renderInContext:ctx];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
   // UIGraphicsEndImageContext();
    
    return image;
}

- (void)takeSnapshotOnTimer:(NSTimer *)t {
    NSLog(@"timer!");
    if (self.didEndRenderingMap && self.didShowLocation) {
        self.snapshot = [self snapshotImage];
        
        self.t = nil;
        [t invalidate];
        [self takeSnapshotWithCompletion:^{
            [self closeItself];
        }];
    }
}

- (void)takeSnapshotWithCompletion:(void (^)())completion {

    if (self.snapshot) {
        [[RTCMediaStore sharedStore] addLocationSnapshotWithImage:self.snapshot andLocation:self.locationManager.location];
        
        if (completion) {
            completion();
        }
    } else {
        if (!self.t) {
            self.t = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(takeSnapshotOnTimer:) userInfo:nil repeats:YES];
        }
    }
    
}
 */
/*
- (void)takeSnapshotWithCompletion:(void (^)())completion {
    [self moveMapToLocation:self.locationManager.location];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(280, 280); // такс такс
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        
        UIImage *image = snapshot.image;
        
        CGRect finalImageRect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Get a standard annotation view pin. Clearly, Apple assumes that we'll only want to draw standard annotation pins!
        
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        
        // ok, let's start to create our final image
        
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        
        // first, draw the image from the snapshotter
        
        [image drawAtPoint:CGPointMake(0, 0)];
        
        // now, let's iterate through the annotations and draw them, too
        
        for (id<MKAnnotation>annotation in self.mapView.annotations)
        {
            CGPoint point = [snapshot pointForCoordinate:annotation.coordinate];
            if (CGRectContainsPoint(finalImageRect, point)) // this is too conservative, but you get the idea
            {
                CGPoint pinCenterOffset = pin.centerOffset;
                point.x -= pin.bounds.size.width / 2.0;
                point.y -= pin.bounds.size.height / 2.0;
                point.x += pinCenterOffset.x;
                point.y += pinCenterOffset.y;
                
                [pinImage drawAtPoint:point];
            }
        }
        
        // grab the final image
        
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [[RTCMediaStore sharedStore] addLocationSnapshotWithImage:finalImage andLocation:self.locationManager.location];
        
        if (completion) {
            completion();
        }

    }];
    
 
    
}
*/

- (void)takeSnapshotOnTimer:(NSTimer *)t {
    NSLog(@"timer!");
    if (self.didEndRenderingMap && self.didShowLocation) {

        [self snapshotImageWithCompletion:^{
            self.t = nil;
            [t invalidate];
            [self takeSnapshotWithCompletion:^{
                [self closeItself];
            }];
        }];

        
    }
}

- (void)takeSnapshotWithCompletion:(void (^)())completion {
    
    if (self.snapshot) {
        [[RTCMediaStore sharedStore] addLocationSnapshotWithImage:self.snapshot andLocation:self.locationManager.location];
        
        if (completion) {
            completion();
        }
    } else {
        if (!self.t) {
            self.t = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(takeSnapshotOnTimer:) userInfo:nil repeats:YES];
        }
    }
    
}

- (void)snapshotImageWithCompletion:(void (^)())completion {
  //  [self moveMapToLocation:self.locationManager.location];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.region = self.mapView.region;
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(280, 280); // такс такс
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
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
        [snapshotter cancel];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
                
            });

        }
        
    }];

    
}

@end
