//
//  RTCMessagesStore.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTCMessageMedia.h"

@class RTCMessage;

@interface RTCMessageStore : NSObject

@property (nonatomic, readonly) NSArray *allMessages;

+ (instancetype)sharedStore;

- (RTCMessage *)createMessageWithDate:(NSDate *)date text:(NSString *)text;
- (RTCMessage *)createMessageWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media;

@end
