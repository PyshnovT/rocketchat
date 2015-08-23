//
//  RTCMessage.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCMessageMedia.h"

@interface RTCMessage : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) id<RTCMessageMedia> media;

- (instancetype)initWithDate:(NSDate *)date text:(NSString *)text;
- (instancetype)initWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media;

@end
