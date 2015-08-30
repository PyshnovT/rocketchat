//
//  RTCStatusBarView.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 30/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCStatusBarView.h"

@implementation RTCStatusBarView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);
    
    CGContextStrokePath(context);
}


@end
