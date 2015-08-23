//
//  RTCMessageCollectionViewLayout.m
//  Rocketchat
//
//  Created by Тимофей Пышнов on 23/08/15.
//  Copyright (c) 2015 Pyshnov. All rights reserved.
//

#import "RTCMessageCollectionViewLayout.h"


@interface RTCMessageCollectionViewLayout ()

@property (nonatomic, strong) NSDictionary *layoutInfo;

@end

@implementation RTCMessageCollectionViewLayout

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
    self.itemInsets = UIEdgeInsetsMake(40, 0, 40, 20);
    self.itemSize = CGSizeMake(230, 100);
    self.interItemSpacingY = 8;
}

#pragma mark - Layout

- (CGSize)collectionViewContentSize {
    NSInteger rowCount = [[RTCMessageStore sharedStore] allMessages].count;
    CGFloat height = self.itemInsets.top + rowCount * self.itemSize.height + (rowCount - 1) * self.interItemSpacingY + self.itemInsets.bottom;
    return CGSizeMake(self.collectionView.bounds.size.width, height);
}

- (void)prepareLayout {
    NSMutableDictionary *newLayoutInfo = [NSMutableDictionary dictionary];
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        for (NSInteger item = 0; item < itemCount; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            itemAttributes.frame = [self frameForMessageAtIndexPath:indexPath];
            
            cellLayoutInfo[indexPath] = itemAttributes;
        }
    }
    
    newLayoutInfo[@"Cell"] = cellLayoutInfo;
    
    self.layoutInfo = newLayoutInfo;
}

- (CGRect)frameForMessageAtIndexPath:(NSIndexPath *)indexPath {
        // Переписать для сообщений разного размера
    CGFloat x = self.collectionView.bounds.size.width - self.itemInsets.right - self.itemSize.width;
    CGFloat y = (self.interItemSpacingY + self.itemSize.height) * indexPath.row + self.itemInsets.top;
    
    return CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
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

@end
