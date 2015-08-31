//
//  RTCMediaStore.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 28/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class CLLocation;
@class RTCMessageImageMediaItem;
@class RTCMessageLocationMediaItem;

//
//
// This object manages data for media messages that haven't been sent yet for easy retrieving 
//
//


typedef enum {
    MediaTypePhoto,
    MediaTypeImage,
    MediaTypeLocation,
    MediaTypeNone
} MediaType;

@interface RTCMediaStore : NSObject

@property (nonatomic, readonly) NSDictionary *allMediaData;
@property (nonatomic) MediaType currentMediaType;

+ (instancetype)sharedStore;

- (void)addImageFromGallery:(UIImage *)image;
- (void)cleanImageGallery;
- (NSArray *)imageGalleryItems;


- (void)addLocationSnapshotWithImage:(UIImage *)snapshotImage andLocation:(CLLocation *)location;
- (RTCMessageLocationMediaItem *)locationSnapshot;
- (void)cleanLocationSnapshot;

@end
