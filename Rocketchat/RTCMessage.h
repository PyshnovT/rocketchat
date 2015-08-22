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

- (instancetype)initWithDate:(NSDate *)date text:(NSString *)text;
- (instancetype)initWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media;
 
@end
