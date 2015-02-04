//
//  FLSWaterfallCollectionViewLayout_Dragging.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/30/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSWaterfallCollectionViewLayout.h"

@interface FLSWaterfallCollectionViewLayout ()
- (void)beginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)endDragging;
- (void)cancelDragging;

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture;
@end
