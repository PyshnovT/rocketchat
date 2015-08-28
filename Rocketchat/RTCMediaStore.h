//
//  RTCMediaStore.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 28/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
//
// This object manages data for media messages that haven't been sent yet for easy retrieving 
//
//

@interface RTCMediaStore : NSObject

@property (nonatomic, readonly) NSDictionary *allMediaData;

+ (instancetype)sharedStore;
- (void)addImageFromGallery:(UIImage *)image;

- (NSArray *)imageGalleryItems;

@end
