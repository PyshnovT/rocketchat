//
//  RTCPhotoTakerController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 30/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    PhotoScreenModeShort,
    PhotoScreenModeFull
} PhotoScreenMode;

@class RTCMainViewController;

@interface RTCPhotoTakerController : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) RTCMainViewController *mvc;
@property (nonatomic) PhotoScreenMode screenMode;

@end
