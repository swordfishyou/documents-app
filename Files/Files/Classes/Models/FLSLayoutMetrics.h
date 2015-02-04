//
//  FLSLayoutMetrics.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@interface FLSColumnLayoutMetrics : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) NSMutableIndexSet *itemIndexes;

- (void)appendHeightPart:(CGFloat)height;
- (void)setColumnWidth:(CGFloat)width;

- (void)addItemIndex:(NSInteger)index;
@end