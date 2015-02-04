//
//  FLSLayoutMetrics.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSLayoutMetrics.h"

@implementation FLSColumnLayoutMetrics
- (instancetype)init {
    if (self = [super init]) {
        _itemIndexes = [NSMutableIndexSet indexSet];
        _size = CGSizeZero;
    }
    
    return self;
}
- (void)addItemIndex:(NSInteger)index {
    [self.itemIndexes addIndex:index];
}

- (void)appendHeightPart:(CGFloat)height {
    _size.height += height;
}

- (void)setColumnWidth:(CGFloat)width {
    _size.width = width;
}
@end
