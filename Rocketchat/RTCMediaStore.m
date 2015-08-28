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

@interface RTCMediaStore ()

@property (nonatomic, strong) NSMutableDictionary *privateMediaData;

@end

@implementation RTCMediaStore

static NSString * const photoGalleryIdentifier = @"photoGalleryMediaItems";

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
                                                                                [NSMutableArray array]}];
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

#pragma mark - Adding Media Items

- (void)addImageFromGallery:(UIImage *)image {
    RTCMessageImageMediaItem *photoItem = [RTCMessageImageMediaItem itemWithImage:image];
    
    [self.privateMediaData[photoGalleryIdentifier] addObject:photoItem];
}


@end
