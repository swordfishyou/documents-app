//
//  FLSWaterfallCollectionViewLayout.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSWaterfallCollectionViewLayout_Internal.h"
#import "FLSWaterfallCollectionViewLayout_Gestures.h"
#import "FLSWaterfallCollectionViewLayout_Dragging.h"

@interface FLSCollectionViewLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext
@property (nonatomic, assign) BOOL invalidateLayoutMetrics;
@end

@implementation FLSCollectionViewLayoutInvalidationContext
@end

@implementation FLSWaterfallCollectionViewLayout
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    _columnsBySection = [NSMutableDictionary dictionary];
    _columnMetricsByIndexPath = [NSMutableDictionary dictionary];
    _itemAttributesByIndexPath = [NSMutableDictionary dictionary];
    _itemSizesByIndexPath = [NSMutableDictionary dictionary];
    _layoutAttributes = [NSMutableArray array];
    
    _numberOfColumnsInSection = 1;
    _minimumInterlineSpacing = 5.0;
    _minimumItercolumnSpacing = 5.0;
    _estimatedItemSize = CGSizeMake(100, 100);
    _lastTranslation = CGPointZero;
    _autoscrollTriggerInsets = UIEdgeInsetsMake(100, 0, 100, 0);
}

#pragma mark - UICollectionViewLayout
+ (Class)invalidationContextClass {
    return [FLSCollectionViewLayoutInvalidationContext class];
}

- (void)prepareLayout {
    if (!CGRectIsEmpty(self.collectionView.bounds)) {
        [self buildLayout];
    }
    
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize {
    return self.layoutSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = self.itemAttributesByIndexPath[indexPath];
    if (attributes) {
        return attributes;
    }
    
    attributes = [[self.class layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [self itemFrameAtIndexPath:indexPath];
    attributes.hidden = [self.lastSourceIndexPath isEqual:indexPath] || [self.draggingIndexPath isEqual:indexPath];
    if (!self.isPreparingLayout) {
        self.itemAttributesByIndexPath[indexPath] = attributes;
    }
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attribute in self.layoutAttributes) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [attributes addObject:attribute];
        }
    }
    
    return attributes;
}

- (void)invalidateLayoutWithContext:(FLSCollectionViewLayoutInvalidationContext *)context {
    if (context.invalidateDataSourceCounts || context.invalidateEverything || context.invalidateLayoutMetrics) {
        self.layoutDataValid = NO;
    }
    
    [super invalidateLayoutWithContext:context];
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    FLSCollectionViewLayoutInvalidationContext *context = (FLSCollectionViewLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    CGRect bounds = self.collectionView.bounds;
    context.invalidateLayoutMetrics = (newBounds.size.width != bounds.size.width) || (newBounds.origin.x != bounds.origin.x);
    return context;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - Private
- (void)buildLayout {
    if (self.isPreparingLayout) {
        return;
    }
    
    self.preparingLayout = YES;
    if (!self.isLayoutDataValid) {
        [self buildLayoutFromDataSource];
        self.layoutDataValid = YES;
    }
    
    self.layoutSize = CGSizeZero;
    [self.layoutAttributes removeAllObjects];
    [self calculateLayoutAttributes];
    self.preparingLayout = NO;
}

- (void)buildLayoutFromDataSource {
    [self resetLayoutMetrics];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        NSInteger numberOfColumnsInSection = self.numberOfColumnsInSection;
        if ([self.delegate respondsToSelector:@selector(collectionView:waterfallLayout:numberOfColumnsInSection:)]) {
            numberOfColumnsInSection = [self.delegate collectionView:self.collectionView waterfallLayout:self numberOfColumnsInSection:section];
        }
        
        self.columnsBySection[@(section)] = @(numberOfColumnsInSection);
        
        NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < numberOfItemsInSection; ++item) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            [self calculateSizeOfItemAtIndexPath:indexPath];
        }
        
        [self calculateSizeOfColumnsInSection:section];
    }
}

- (void)resetLayoutMetrics {
    [self.columnsBySection removeAllObjects];
    [self.columnMetricsByIndexPath removeAllObjects];
    [self.itemAttributesByIndexPath removeAllObjects];
    [self.itemSizesByIndexPath removeAllObjects];
}

#pragma mark - Size calculations
- (void)calculateSizeOfItemAtIndexPath:(NSIndexPath *)indexPath {
    FLSDataSource *dataSource = (FLSDataSource *)self.collectionView.dataSource;
    if (![dataSource isKindOfClass:[FLSDataSource class]]) {
        dataSource = nil;
    }
    
    CGSize size;
    if ([self.delegate respondsToSelector:@selector(collectionView:waterfallLayout:sizeOfItemAtIndexPath:)]) {
        size = [self.delegate collectionView:self.collectionView waterfallLayout:self sizeOfItemAtIndexPath:indexPath];
    } else {
        size = [dataSource collectionView:self.collectionView sizeFittingSize:self.estimatedItemSize forItemAtIndexPath:indexPath];
    }
    
    NSInteger numberOfColumnsInSection = [self numberOfColumnsInSection:indexPath.section];
    NSInteger itemColumnIndex = indexPath.item % numberOfColumnsInSection;
    NSUInteger indexes[] = {indexPath.section, itemColumnIndex};
    NSIndexPath *columnIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    FLSColumnLayoutMetrics *columnMetrics = self.columnMetricsByIndexPath[columnIndexPath];
    if (columnMetrics == nil) {
        columnMetrics = [FLSColumnLayoutMetrics new];
        columnMetrics.index = itemColumnIndex;
        columnMetrics.section = indexPath.section;
        self.columnMetricsByIndexPath[columnIndexPath] = columnMetrics;
    }
    
    [columnMetrics addItemIndex:indexPath.item];
    [columnMetrics appendHeightPart:(size.height + self.minimumInterlineSpacing)];
    
    self.itemSizesByIndexPath[indexPath] = [NSValue valueWithCGSize:size];
}

- (void)calculateSizeOfColumnsInSection:(NSInteger)section {
    NSInteger numberOfColumnsInSection = [self numberOfColumnsInSection:section];
    for (NSInteger column = 0; column < numberOfColumnsInSection; ++column) {
        CGFloat width;
        if ([self.delegate respondsToSelector:@selector(collectionView:waterfallLayout:widthOfColumn:inSection:)]) {
            width = [self.delegate collectionView:self.collectionView waterfallLayout:self widthOfColumn:column inSection:section];
        } else {
            CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
            UIEdgeInsets contentInset = self.collectionView.contentInset;
            CGFloat layoutWidth = collectionViewWidth - contentInset.left - contentInset.right - (numberOfColumnsInSection - 1) * self.minimumItercolumnSpacing;
            width = layoutWidth / numberOfColumnsInSection;
        }
        
        FLSColumnLayoutMetrics *columnMetrics = [self columnMetricsAtIndex:column inSection:section];
        [columnMetrics setColumnWidth:width];
    }
}

- (void)calculateLayoutAttributes {
    CGFloat height = 0.0;
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        height += [self heightOfSection:section];
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < numberOfItems; ++item) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [self.layoutAttributes addObject:attributes];
            self.itemAttributesByIndexPath[indexPath] = attributes;
        }
    }
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    height -= contentInset.top;
    CGFloat width = collectionViewWidth - contentInset.left - contentInset.right;
    self.layoutSize = CGSizeMake(roundf(width), roundf(height));
    self.layoutDataValid = YES;
}

- (NSInteger)numberOfColumnsInSection:(NSInteger)section {
    return [self.columnsBySection[@(section)] integerValue];
}

- (FLSColumnLayoutMetrics *)columnMetricsAtIndex:(NSInteger)column inSection:(NSInteger)section {
    NSUInteger indexes[] = {section, column};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    return self.columnMetricsByIndexPath[indexPath];
}

- (CGFloat)heightOfSection:(NSInteger)section {
    NSArray *allColumns = [self.columnMetricsByIndexPath allValues];
    NSArray *sectionColumns = [allColumns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"section == %i", section]];
    __block CGFloat height = 0;
    [sectionColumns enumerateObjectsUsingBlock:^(FLSColumnLayoutMetrics *obj, NSUInteger idx, BOOL *stop) {
        if (obj.size.height > height) {
            height = obj.size.height;
        }
    }];
    
    return height;
}

#pragma mark - Frame calculation
- (CGRect)itemFrameAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame;
    frame.size = [self.itemSizesByIndexPath[indexPath] CGSizeValue];
    
    CGFloat topOffset = 0.0;
    for (NSInteger section = 0; section < indexPath.section; ++section) {
        topOffset += [self heightOfSection:section];
    }
    
    NSInteger numberOfColumnsInSection = [self numberOfColumnsInSection:indexPath.section];
    NSInteger itemColumn = indexPath.item % numberOfColumnsInSection;
    FLSColumnLayoutMetrics *columnMetrics = [self columnMetricsAtIndex:itemColumn inSection:indexPath.section];
    for (NSInteger item = 0; item < indexPath.item; ++item) {
        if ([columnMetrics.itemIndexes containsIndex:item]) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:item inSection:indexPath.section];
            topOffset += [self.itemSizesByIndexPath[ip] CGSizeValue].height;
            topOffset += self.minimumInterlineSpacing;
        }
    }
    frame.origin.y = topOffset;
    
    CGFloat leftOffset = 0.0;
    leftOffset += itemColumn * self.minimumItercolumnSpacing;
    for (NSInteger column = 0; column < itemColumn; ++column) {
        FLSColumnLayoutMetrics *metrics = [self columnMetricsAtIndex:column inSection:indexPath.section];
        leftOffset += metrics.size.width;
    }
    CGFloat columnWidth = columnMetrics.size.width;
    leftOffset += (columnWidth - CGRectGetWidth(frame)) / 2.0;
    frame.origin.x = leftOffset;
    return frame;
}

#pragma mark - Drag and drop
- (void)beginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.draggingIndexPath =  indexPath;
    self.lastSourceIndexPath = indexPath;
    self.sourceIndexPath = indexPath;
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIView *snapshot = [cell snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = cell.frame;
    
    self.draggingView = snapshot;
    self.draggingView.alpha = 0;
    [self.collectionView addSubview:self.draggingView];
    
    self.dragBounds = CGRectMake(CGRectGetWidth(cell.frame) / 2.0,
                                 CGRectGetHeight(cell.frame) / 2.0,
                                 CGRectGetWidth(self.collectionView.bounds) - CGRectGetWidth(cell.frame),
                                 CGRectGetHeight(self.collectionView.bounds) - CGRectGetHeight(cell.frame));
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.draggingView.alpha = 0.75;
                         self.draggingView.transform = CGAffineTransformScale(self.draggingView.transform, 1.1, 1.1);
                     } completion:^(BOOL finished) {
                         FLSCollectionViewLayoutInvalidationContext *context = [FLSCollectionViewLayoutInvalidationContext new];
                         context.invalidateLayoutMetrics = YES;
                         [self invalidateLayoutWithContext:context];
                     }];
}

- (void)endDragging {
    FLSDataSource *dataSource = self.collectionView.dataSource;
    if (![dataSource isKindOfClass:[FLSDataSource class]]) {
        dataSource = nil;
    }
    
    [dataSource collectionView:self.collectionView moveItemAtIndexPath:self.sourceIndexPath toIndexPath:self.draggingIndexPath isHeld:NO];
    [self cancelDragging];
}

- (void)cancelDragging {
    [self.draggingView removeFromSuperview];
    self.draggingView = nil;
    
    self.sourceIndexPath = nil;
    self.draggingIndexPath = nil;
    self.lastSourceIndexPath = nil;
    self.lastTranslation = CGPointZero;
    self.autosctollVelocity = 0;
    [self invalidateAutoscrollTimer];
    [self invalidateDraggingHoldTimer];
    
    FLSCollectionViewLayoutInvalidationContext *context = [FLSCollectionViewLayoutInvalidationContext new];
    context.invalidateLayoutMetrics = YES;
    [self invalidateLayoutWithContext:context];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged:{
            [self scheduleDraggingHoldTimer];
            
            CGPoint translation = [gesture translationInView:self.collectionView];
            CGPoint diff = FLSPointSubtractPoint(translation, self.lastTranslation);
            self.lastTranslation = translation;
            CGPoint center = FLSPointAddPoint(self.draggingView.center, diff);
            [self constrainPointToDragBounds:&center];
            self.draggingView.center = center;
            
            CGRect autoscrollFrame = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.autoscrollTriggerInsets);
            CGPoint location = [gesture locationInView:self.collectionView];
            CGFloat top = CGRectGetMinY(autoscrollFrame);
            CGFloat bottom = CGRectGetMaxY(autoscrollFrame);
            
            if (location.y < top) {
                self.autosctollVelocity = 10 * (top - location.y);
                [self scheduleAutoscrollTimerWithDirection:FLSAutoscrollDirectionUp];
            } else if (location.y > bottom) {
                self.autosctollVelocity = 10 * (location.y - bottom);
                [self scheduleAutoscrollTimerWithDirection:FLSAutoscrollDirectionDown];
            } else {
                [self invalidateAutoscrollTimer];
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self invalidateAutoscrollTimer];
            [self invalidateDraggingHoldTimer];
            break;
            
        default:
            break;
    }
}

- (void)constrainPointToDragBounds:(CGPoint *)point {
    CGFloat left = CGRectGetMinX(self.dragBounds);
    CGFloat right = CGRectGetMaxX(self.dragBounds);
    
    if (point->x > right) {
        point->x = right;
    } else if (point->x < left) {
        point->x = left;
    }
}

#pragma mark - Autoscroll
- (void)scheduleAutoscrollTimerWithDirection:(FLSAutoscrollDirection)direction {
    if (_autoscrollTimer && !_autoscrollTimer.paused) {
        return;
    }
    [self invalidateDraggingHoldTimer];
    [self invalidateAutoscrollTimer];
    _autoscrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleAutoscroll:)];
    self.autoscrollDirection = direction;
    [self.autoscrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)handleAutoscroll:(CADisplayLink *)displayLink {
    CGFloat distance = rintf(self.autosctollVelocity / 60.0);
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    switch (self.autoscrollDirection) {
        case FLSAutoscrollDirectionDown: {
            CGFloat maxY = self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds);
            if ((contentOffset.y + contentInset.top + distance) >= maxY) {
                distance = maxY - contentInset.top - contentOffset.y;
            }
            break;
        }
            
        default:
            distance = -distance;
            if ((contentOffset.y + contentInset.top + distance) <= FLT_EPSILON) {
                distance = -contentOffset.y - contentInset.top;
            }
            break;
    }
        
    if (abs(distance) < 1) {
        [self invalidateAutoscrollTimer];
        [self scheduleDraggingHoldTimer];
    }
    
    CGPoint translation = CGPointMake(0, distance);
    CGPoint center = FLSPointAddPoint(self.draggingView.center, translation);
    [self constrainPointToDragBounds:&center];
    self.draggingView.center = center;
    self.collectionView.contentOffset = FLSPointAddPoint(self.collectionView.contentOffset, translation);
}

- (void)invalidateAutoscrollTimer {
    if (!self.autoscrollTimer.paused) {
        [self.autoscrollTimer invalidate];
    }
    
    _autoscrollTimer = nil;
}

- (void)scheduleDraggingHoldTimer {
    if (_draggingHoldTimer) {
        [self invalidateDraggingHoldTimer];
    }
    
    _draggingHoldTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(handleDraggindHold:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.draggingHoldTimer forMode:NSRunLoopCommonModes];
}

- (void)handleDraggindHold:(NSTimer *)timer {
    FLSDataSource *dataSource = (FLSDataSource *)self.collectionView.dataSource;
    if (![dataSource isKindOfClass:[FLSDataSource class]]) {
        dataSource = nil;
    }
    
    NSIndexPath *newIndexPath = [self.collectionView indexPathForItemAtPoint:self.draggingView.center];
    if (newIndexPath != nil && ![newIndexPath isEqual:self.draggingIndexPath]) {
        BOOL canMove = [dataSource collectionView:self.collectionView canMoveItemAtIndexPath:self.lastSourceIndexPath toIndexPath:newIndexPath];
        
        if (canMove) {
            self.draggingIndexPath = newIndexPath;
            [dataSource collectionView:self.collectionView moveItemAtIndexPath:self.lastSourceIndexPath toIndexPath:newIndexPath isHeld:YES];
            self.lastSourceIndexPath = newIndexPath;
            
            FLSCollectionViewLayoutInvalidationContext *context = [FLSCollectionViewLayoutInvalidationContext new];
            context.invalidateLayoutMetrics = YES;
            [self invalidateLayoutWithContext:context];
        }
    }
}

- (void)invalidateDraggingHoldTimer {
    [self.draggingHoldTimer invalidate];
    _draggingHoldTimer = nil;
}
@end