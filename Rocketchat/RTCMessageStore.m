//
//  RTCMessagesStore.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 22/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageStore.h"
#import "RTCMessage.h"
#import "RTCMessageMedia.h"

@interface RTCMessageStore ()

@property (nonatomic) NSMutableArray *privateMessages;

@end

@implementation RTCMessageStore

#pragma mark - init

+ (instancetype)sharedStore {
    static RTCMessageStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[RTCMessageStore sharedStore]" userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _privateMessages = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Property Accessory

- (NSArray *)allMessages {
    return self.privateMessages;
}

#pragma mark - Creating new message


- (RTCMessage *)createMessageWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media withParseId:(NSString *)parseId {
    if (text && media) return nil;
    
    RTCMessage *newMessage;
    
    if (text) {
        newMessage = [[RTCMessage alloc] initWithDate:date text:text withParseId:parseId];
    } else if (media) {
        newMessage = [[RTCMessage alloc] initWithDate:date media:media withParseId:parseId];
    } else {
        newMessage = [[RTCMessage alloc] initWithDate:date media:media withParseId:parseId];
    }
    
    NSLog(@"Image object! %@", newMessage);
    
    if (!parseId) {
        [self.privateMessages addObject:newMessage];
    } else {
        [self.privateMessages insertObject:newMessage atIndex:0];
    }
    
    return newMessage;
}


- (RTCMessage *)createMessageWithDate:(NSDate *)date text:(NSString *)text withParseId:(NSString *)parseId {
    return [self createMessageWithDate:date text:text media:nil withParseId:parseId];
}

- (RTCMessage *)createMessageWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media withParseId:(NSString *)parseId {
    return [self createMessageWithDate:date text:nil media:media withParseId:parseId];
}

- (void)removeMessageAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    [self.privateMessages removeObjectAtIndex:row];
}

@end