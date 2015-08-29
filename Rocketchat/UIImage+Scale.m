//
//  UIImage+Scale.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 29/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

#pragma mark - Convenience methods

- (UIImage *)scaleImageToFillWithSize:(CGSize)newSize {
    return [self scaleImageToSize:newSize toFill:YES];
}

- (UIImage *)scaleImageToFitWithSize:(CGSize)newSize {
    return [self scaleImageToSize:newSize toFill:NO];
}

- (CGSize)imageSizeToFillSize:(CGSize)newSize {
    return [self imageSizeToFill:YES newSize:newSize];
}

- (CGSize)imageSizeToFitSize:(CGSize)newSize {
    return [self imageSizeToFill:NO newSize:newSize];
}

#pragma mark - Internal Methods

- (UIImage *)scaleImageToSize:(CGSize)newSize toFill:(BOOL)toFill {
    CGRect scaledImageRect = CGRectZero;
    
    CGSize scaledImageSize = [self imageSizeToFill:toFill newSize:newSize];
    
    scaledImageRect.size.width = scaledImageSize.width;
    scaledImageRect.size.height = scaledImageSize.height;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
    
    [self drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (CGSize)imageSizeToFill:(BOOL)toFill newSize:(CGSize)newSize {
    CGFloat aspectWidth = newSize.width / self.size.width;
    CGFloat aspectHeight = newSize.height / self.size.height;
    
    CGFloat aspectRatio;
    
    if (toFill) {
        aspectRatio = MAX(aspectWidth, aspectHeight);
    } else {
        aspectRatio = MIN(aspectWidth, aspectHeight);
    }
    
    return CGSizeMake(self.size.width * aspectRatio, self.size.height * aspectRatio);
}


#pragma mark - Width

- (UIImage *)scaleImageToFillWidth:(CGFloat)width {
    CGRect scaledImageRect = CGRectZero;
    
    CGSize scaledImageSize = [self imageSizeToFillWidth:width];
    
    scaledImageRect.size.width = scaledImageSize.width;
    scaledImageRect.size.height = scaledImageSize.height;
    scaledImageRect.origin.x = 0;
    scaledImageRect.origin.y = 0;
    
    UIGraphicsBeginImageContextWithOptions(scaledImageSize, NO, 0 );
    
    [self drawInRect:scaledImageRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (CGSize)imageSizeToFillWidth:(CGFloat)width {
    CGFloat aspectRatio = width / self.size.width;
    
    return CGSizeMake(aspectRatio * self.size.width, aspectRatio * self.size.height);
}

@end
