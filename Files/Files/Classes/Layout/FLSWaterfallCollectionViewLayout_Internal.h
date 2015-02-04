//
//  FLSWaterfallCollectionViewLayout_Internal.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSWaterfallCollectionViewLayout.h"
#import "FLSDataSource.h"
#import "FLSLayoutMetrics.h"

@interface FLSWaterfallCollectionViewLayout ()
/// Numbers of columns mapped by section index
@property (nonatomic, strong) NSMutableDictionary *columnsBySection;
/// Index path object hast to have section and column indexes: [section, column]
@property (nonatomic, strong) NSMutableDictionary *columnMetricsByIndexPath;
/// Item sizes mapped by item indexPath
@property (nonatomic, strong) NSMutableDictionary *itemSizesByIndexPath;
/// Item attributes by item indexPath
@property (nonatomic, strong) NSMutableDictionary *itemAttributesByIndexPath;
/// Layout attributes of all the views in collection view
@property (nonatomic, strong) NSMutableArray *layoutAttributes;
@property (nonatomic, assign) CGSize layoutSize;
/// Indicates layout is building or not
@property (nonatomic, assign, getter=isPreparingLayout) BOOL preparingLayout;
@property (nonatomic, assign, getter=isLayoutDataValid) BOOL layoutDataValid;

- (void)commonInit;
- (void)buildLayout;
- (void)buildLayoutFromDataSource;
- (void)resetLayoutMetrics;
- (void)calculateSizeOfColumnsInSection:(NSInteger)section;
- (void)calculateSizeOfItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)calculateLayoutAttributes;
- (CGRect)itemFrameAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfColumnsInSection:(NSInteger)section;
- (CGFloat)heightOfSection:(NSInteger)section;
@end
