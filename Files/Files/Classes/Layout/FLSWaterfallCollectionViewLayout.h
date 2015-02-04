//
//  FLSWaterfallCollectionViewLayout.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@protocol FLSWaterfallCollectionViewLayoutDelegate;

extern CGFloat const FLSColumnWidthUnknown;

@interface FLSWaterfallCollectionViewLayout : UICollectionViewLayout
/// Number of columns it all the sections. Equals 1 by default
/// Use this property if columns have to have equal widths
@property (nonatomic, assign) NSInteger numberOfColumnsInSection;
/// Actual size of an item's frame. Frame's hotizontal origin is centered in a column
/// Layout will use this value without any size calculations
@property (nonatomic, assign) CGSize itemSize;
/// Estimated size of an item. Layout will calculate actual size using this value
@property (nonatomic, assign) CGSize estimatedItemSize;
/// Minimal interval between columns. 5 points by default
@property (nonatomic, assign) CGFloat minimumItercolumnSpacing;
/// Minimal interval between items in one column. 5 points by default
@property (nonatomic, assign) CGFloat minimumInterlineSpacing;
/// Delegate object to provide more details about collection view items and views
@property (nonatomic, weak) id<FLSWaterfallCollectionViewLayoutDelegate> delegate;
@end

@protocol FLSWaterfallCollectionViewLayoutDelegate <NSObject>
@optional
- (NSInteger)collectionView:(UICollectionView *)collectionView waterfallLayout:(FLSWaterfallCollectionViewLayout *)layout numberOfColumnsInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView waterfallLayout:(FLSWaterfallCollectionViewLayout *)layout widthOfColumn:(NSInteger)column inSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView waterfallLayout:(FLSWaterfallCollectionViewLayout *)layout sizeOfItemAtIndexPath:(NSIndexPath *)indexPath;
@end