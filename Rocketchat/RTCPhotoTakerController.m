//
//  RTCPhotoTakerController.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 30/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCPhotoTakerController.h"
#import "RTCMainViewController.h"
#import "RTCMediaStore.h"

@interface RTCPhotoTakerController ()



@end

@implementation RTCPhotoTakerController 

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalPhoto = info[UIImagePickerControllerOriginalImage];
    [[RTCMediaStore sharedStore] addTakenPhoto:originalPhoto];
    

    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
    [self.mvc sendTakenPhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.mvc closeOpenedMediaContainerIfNeededWithCompletion:nil];
}

@end
