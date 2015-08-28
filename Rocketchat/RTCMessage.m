//
//  RTCMessage.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessage.h"

@interface RTCMessage ()

@end

@implementation RTCMessage

 // Designated initializer
- (instancetype)initWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media {
    if ((media && text) || (!media && !text)) return nil;

    self = [super init];
    if (self) {
        if (!date) date = [NSDate date];
        
        self.date = date;
        self.text = text;
        self.media = media;
        
    }
    return self;
    
}
 
- (instancetype)initWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media {
    return [self initWithDate:date text:nil media:media];
}
 
- (instancetype)initWithDate:(NSDate *)date text:(NSString *)text {
    return [self initWithDate:date text:text media:nil];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use -(instancetype)initWithDate..." userInfo:nil];
    return nil;
}


 

@end
