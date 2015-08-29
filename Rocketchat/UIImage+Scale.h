//
//  UIImage+Scale.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 29/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Scale)


- (UIImage *)scaleImageToFillWithSize:(CGSize)newSize;
- (UIImage *)scaleImageToFitWithSize:(CGSize)newSize;

- (CGSize)imageSizeToFillSize:(CGSize)newSize;
- (CGSize)imageSizeToFitSize:(CGSize)newSize;


- (UIImage *)scaleImageToFillWidth:(CGFloat)width;
- (CGSize)imageSizeToFillWidth:(CGFloat)width;

@end
