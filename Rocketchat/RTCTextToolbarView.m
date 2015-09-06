//
//  RTCTextToolbarView.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 25/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCTextToolbarView.h"

@implementation RTCTextToolbarView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"draw rect");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    
    NSInteger inset = 8;
    
    CGContextMoveToPoint(context, CGRectGetMinX(rect) + inset, CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect) - inset, CGRectGetMaxY(rect));
    
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokePath(context);

    CGContextStrokePath(context);
}


@end
