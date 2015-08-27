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

@interface RTCCollectionViewController : UICollectionViewController

- (void)addMessageWithDate:(NSDate *)date text:(NSString *)text media:(id<RTCMessageMedia>)media;
- (void)scrollToNewestMessage;

@end
