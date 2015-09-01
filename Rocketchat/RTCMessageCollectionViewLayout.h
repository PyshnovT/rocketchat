//
//  RTCMessageCollectionViewLayout.h
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCMessageStore.h"

@interface RTCMessageCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, strong) NSMutableDictionary *cellBottomY;

@property (nonatomic) CGFloat ticketOffset;

@property (nonatomic) UIEdgeInsets collectionViewInsets;
@property (nonatomic) UIEdgeInsets messageBubbleInsets;
@property (nonatomic) CGSize messageSize;
@property (nonatomic) CGFloat interMessageSpacingY;

@property (nonatomic, strong) UIFont *messageFont;

- (CGSize)sizeForMessageAtIndexPath:(NSIndexPath *)indexPath;

@end
