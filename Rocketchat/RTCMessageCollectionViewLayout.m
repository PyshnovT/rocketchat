//
//  RTCMessageCollectionViewLayout.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageCollectionViewLayout.h"
#import "RTCMessage.h"
#import "RTCMessageMedia.h"

#import "UIImage+Scale.h"

@interface RTCMessageCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo; // Object for setting messages' frame

@end

@implementation RTCMessageCollectionViewLayout

static NSInteger const tailHeight = 8;

#pragma mark - Initializing

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

- (void)awakeFromNib {
    [self setupLayout];
}

- (void)setupLayout {
    self.cellBottomY = [NSMutableDictionary dictionary];
    
    self.collectionViewInsets = UIEdgeInsetsMake(10, 0, 10, 8);
    self.messageBubbleInsets = UIEdgeInsetsMake(15, 15, 15, 15); // Данные из .xib
    self.messageSize = CGSizeMake(240, 240); // Второй параметр имеет значение только для медиа-сообщений
    self.interMessageSpacingY = 8;
    self.messageFont = [UIFont fontWithName:@"PFAgoraSansPro-Regular" size:16]; 
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    NSInteger rowCount = [[RTCMessageStore sharedStore] allMessages].count;
    NSInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    
    NSIndexPath *lastItemIndexPath = [NSIndexPath indexPathForRow:rowCount-1 inSection:sectionsCount-1];
    CGFloat totalMessagesHeight = self.collectionViewInsets.top + [self.cellBottomY[lastItemIndexPath] floatValue] + self.collectionViewInsets.bottom;
    
    CGFloat height = totalMessagesHeight;
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath;
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
            
            CGFloat newBottomY = [self.cellBottomY[previousIndexPath] floatValue] + self.interMessageSpacingY + [self sizeForMessageAtIndexPath:indexPath].height;
            
            self.cellBottomY[indexPath] = [NSNumber numberWithFloat:newBottomY];
          //  NSLog(@"%@", self.cellBottomY);
    
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            itemAttributes.frame = [self frameForMessageAtIndexPath:indexPath];

            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[@"Cell"] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    for (NSString *key in self.layoutInfo) {
        
        NSDictionary *attributesDict = [self.layoutInfo objectForKey:key];
        
        for (NSIndexPath *key in attributesDict) {
            UICollectionViewLayoutAttributes *attributes = [attributesDict objectForKey:key];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [allAttributes addObject:attributes];
            }
        }
    }
    
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutInfo[@"Cell"][indexPath];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

 
#pragma mark - Messages size and position

- (CGRect)frameForMessageAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat x = self.collectionView.bounds.size.width - self.collectionViewInsets.right - self.messageSize.width;
    
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];
    CGFloat y = self.collectionViewInsets.top + [self.cellBottomY[previousIndexPath] floatValue];
    
    CGSize size = [self sizeForMessageAtIndexPath:indexPath];
    
    return CGRectMake(x, y, size.width, size.height);
}

- (CGSize)sizeForMessageAtIndexPath:(NSIndexPath *)indexPath {
    RTCMessage *message = [[[RTCMessageStore sharedStore] allMessages] objectAtIndex:indexPath.row];
    
    CGFloat width = self.messageSize.width;
    CGFloat height = 0;
    
    if (message.media) {
        CGFloat imageHeight = [message.media.image imageSizeToFitWidth:self.messageSize.width].height;// message.media.thumbnailImage.size.height;// [message.media.image imageSizeToFitSize:self.messageSize].height;
        
        height = imageHeight + tailHeight;
    } else if (message.text) {
        CGFloat textLabelWidth = self.messageSize.width - self.messageBubbleInsets.left - self.messageBubbleInsets.right;
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              self.messageFont, NSFontAttributeName,
                                              nil];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:message.text attributes:attributesDictionary];
        
        CGRect textRect = [string boundingRectWithSize:CGSizeMake(textLabelWidth, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
        CGSize textSize = CGRectIntegral(textRect).size;
        CGFloat textHeight = MAX(21, textSize.height);
        
        height = self.messageBubbleInsets.top + textHeight + self.messageBubbleInsets.bottom + tailHeight;
    }
    
    return CGSizeMake(width, height);

}


@end
