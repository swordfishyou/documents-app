//
//  FLSGesturesController_Internal.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/30/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSGesturesController.h"
#import "FLSWaterfallCollectionViewLayout_Dragging.h"

@interface FLSGesturesController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, copy) NSIndexPath *draggingIndexPath;

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture;
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;
@end
