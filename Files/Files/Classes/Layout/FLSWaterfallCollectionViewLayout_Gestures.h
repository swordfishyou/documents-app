//
//  FLSWaterfallCollectionViewLayout_Gestures.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/30/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSWaterfallCollectionViewLayout.h"

CGPoint FLSPointAddPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint FLSPointSubtractPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

typedef NS_ENUM(NSUInteger, FLSAutoscrollDirection){
    FLSAutoscrollDirectionUp = 0,
    FLSAutoscrollDirectionDown
};

@interface FLSWaterfallCollectionViewLayout ()
/// Current index path of a dragging item
@property (nonatomic, copy) NSIndexPath *draggingIndexPath;
/// Previous index path of a dragging item
@property (nonatomic, copy) NSIndexPath *lastSourceIndexPath;
/// Initial index path of a dragging item
@property (nonatomic, copy) NSIndexPath *sourceIndexPath;
/// Last translation in collection view
@property (nonatomic, assign) CGPoint lastTranslation;
/// Snapshot of a dragging item's view
@property (nonatomic, strong) UIView *draggingView;
/// Bounds to draggingView may be constrained if -constrainPointToDragBounds: is called
@property (nonatomic, assign) CGRect dragBounds;
@property (nonatomic, strong) CADisplayLink *autoscrollTimer;
/// If draggingView's frame intersects collectionView's bounds inset this value
/// autosctoll is triggered
@property (nonatomic, assign) UIEdgeInsets autoscrollTriggerInsets;
@property (nonatomic, assign) FLSAutoscrollDirection autoscrollDirection;
@property (nonatomic, assign) CGFloat autosctollVelocity;
@property (nonatomic, strong) NSTimer *draggingHoldTimer;

/// Horizontally constrain given point in dragBounds
- (void)constrainPointToDragBounds:(CGPoint *)point;

- (void)scheduleAutoscrollTimerWithDirection:(FLSAutoscrollDirection)direction;
- (void)handleAutoscroll:(CADisplayLink *)displayLink;
- (void)invalidateAutoscrollTimer;

- (void)scheduleDraggingHoldTimer;
- (void)handleDraggindHold:(NSTimer *)timer;
- (void)invalidateDraggingHoldTimer;
@end
