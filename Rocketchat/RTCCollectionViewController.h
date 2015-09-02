//
//  RTCCollectionViewController.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 27/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCMessageMedia.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@class RTCMainViewController;

@interface RTCCollectionViewController : UICollectionViewController

@property (nonatomic, weak) RTCMainViewController *mvc;

- (void)addMessageWithDate:(NSDate *)date text:(NSString *)text withParseId:(NSString *)parseId;
- (void)addMessageWithDate:(NSDate *)date media:(id<RTCMessageMedia>)media withParseId:(NSString *)parseId;

- (void)scrollToNewestMessage;

@end
