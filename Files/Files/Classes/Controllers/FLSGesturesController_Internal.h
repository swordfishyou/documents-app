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
/// Gesture recognizer to provide cell's location on dragging
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
/// Gesture recognizer to enter drag and dpor mode
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
/// Initial index path of a cell being dragged
@property (nonatomic, copy) NSIndexPath *draggingIndexPath;

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture;
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture;
@end
