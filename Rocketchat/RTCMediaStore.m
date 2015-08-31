//
//  RTCMediaStore.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 28/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMediaStore.h"
#import "RTCMessageImageMediaItem.h"
#import "RTCMessageLocationMediaItem.h"
#import <MapKit/MapKit.h>

@interface RTCMediaStore ()

@property (nonatomic, strong) NSMutableDictionary *privateMediaData;

@end

@implementation RTCMediaStore

static NSString * const takenPhotoIdentifier = @"takenPhotoMediaItem";
static NSString * const photoGalleryIdentifier = @"photoGalleryMediaItems";
static NSString * const locationSnapshotIdentifier = @"locationSnapshotMediaItem";

#pragma mark - init

+ (instancetype)sharedStore {
    static RTCMediaStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[RTCMediaStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _privateMediaData = [NSMutableDictionary dictionaryWithDictionary:@{photoGalleryIdentifier:
                                                                                [NSMutableArray array],
                                                                            locationSnapshotIdentifier: [NSMutableArray array],
                                                                            takenPhotoIdentifier: [NSMutableArray array]}];
        _currentMediaType = MediaTypeNone;
    }
    return self;
}

#pragma mark - Property Accessory

- (NSDictionary *)allMediaData {
    return [self.privateMediaData copy];
}

- (NSArray *)imageGalleryItems {
    return self.privateMediaData[photoGalleryIdentifier];
}

- (RTCMessageLocationMediaItem *)locationSnapshot {
    return [self.privateMediaData[locationSnapshotIdentifier] lastObject];
}

- (RTCMessageImageMediaItem *)takenPhoto {
    return [self.privateMediaData[takenPhotoIdentifier] lastObject];
}

#pragma mark - Cleaning

- (void)cleanImageGallery {
    [self.privateMediaData[photoGalleryIdentifier] removeAllObjects];
}

- (void)cleanLocationSnapshot {
    [self.privateMediaData[locationSnapshotIdentifier] removeAllObjects];
}

- (void)cleanTakenPhoto {
    [self.privateMediaData[takenPhotoIdentifier] removeAllObjects];
}

#pragma mark - Adding Media Items

- (void)addImageFromGallery:(UIImage *)image {
    RTCMessageImageMediaItem *imageItem = [RTCMessageImageMediaItem itemWithImage:image];
    
    [self.privateMediaData[photoGalleryIdentifier] addObject:imageItem];
}

- (void)addLocationSnapshotWithImage:(UIImage *)snapshotImage andLocation:(CLLocation *)location {
    [self cleanLocationSnapshot];
    
    RTCMessageLocationMediaItem *locationItem = [RTCMessageLocationMediaItem itemWithImage:snapshotImage andLocation:location];
    
    
    [self.privateMediaData[locationSnapshotIdentifier] addObject:locationItem];
    
}

- (void)addTakenPhoto:(UIImage *)photo {
    [self cleanTakenPhoto];
    
    RTCMessageImageMediaItem *photoItem = [RTCMessageImageMediaItem itemWithImage:photo];
    
    [self.privateMediaData[takenPhotoIdentifier] addObject:photoItem];
}

@end
