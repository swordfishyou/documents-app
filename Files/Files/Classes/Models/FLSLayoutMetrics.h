//
//  FLSLayoutMetrics.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@interface FLSColumnLayoutMetrics : NSObject
/// Index of the column in section
@property (nonatomic, assign) NSInteger index;
/// Colimn's section
@property (nonatomic, assign) NSInteger section;
/// Size of the column
@property (nonatomic, readonly) CGSize size;
/// Indexes of the items in section
@property (nonatomic, readonly) NSMutableIndexSet *itemIndexes;

/// If cell is added to column you have to update column's height
- (void)appendHeightPart:(CGFloat)height;
- (void)setColumnWidth:(CGFloat)width;

/// Assign an item with column
- (void)addItemIndex:(NSInteger)index;
@end