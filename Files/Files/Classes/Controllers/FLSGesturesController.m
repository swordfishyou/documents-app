//
//  FLSGesturesController.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/30/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSGesturesController_Internal.h"

@implementation FLSGesturesController
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    if (self = [super init]) {
        _collectionView = collectionView;
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGestureRecognizer.delegate = self;
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPressGestureRecognizer.delegate = self;
        _longPressGestureRecognizer.minimumPressDuration = 1.0;
        
        for (UIGestureRecognizer *recognizer in collectionView.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                [recognizer requireGestureRecognizerToFail:_panGestureRecognizer];
            }
            
            if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [recognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
            }
        }
        
        [_collectionView addGestureRecognizer:_panGestureRecognizer];
        [_collectionView addGestureRecognizer:_longPressGestureRecognizer];
    }
    
    return self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    FLSWaterfallCollectionViewLayout *layout = (FLSWaterfallCollectionViewLayout *)self.collectionView.collectionViewLayout;
    if (![layout isKindOfClass:[FLSWaterfallCollectionViewLayout class]]) {
        layout = nil;
    }
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
            [layout beginDraggingItemAtIndexPath:self.draggingIndexPath];
            break;
        case UIGestureRecognizerStateEnded:
            [layout endDragging];
            self.draggingIndexPath = nil;
            break;
        case UIGestureRecognizerStateCancelled:
            [layout cancelDragging];
            self.draggingIndexPath = nil;
            break;
            
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    FLSWaterfallCollectionViewLayout *layout = (FLSWaterfallCollectionViewLayout *)self.collectionView.collectionViewLayout;
    if (![layout isKindOfClass:[FLSWaterfallCollectionViewLayout class]]) {
        layout = nil;
    }
    
    if (self.draggingIndexPath != nil) {
        [layout handlePanGesture:panGesture];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _longPressGestureRecognizer) {
        if (self.draggingIndexPath) {
            return NO;
        }
        
        CGPoint location = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        if (indexPath != nil && ![indexPath isEqual:self.draggingIndexPath]) {
            self.draggingIndexPath = indexPath;
            return YES;
        }
        
        return NO;
    }
    
    if (gestureRecognizer == _panGestureRecognizer) {
        return (self.draggingIndexPath != nil);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isEqual:self.longPressGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:self.panGestureRecognizer];
    } else if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        return [otherGestureRecognizer isEqual:self.longPressGestureRecognizer];
    }
    
    return NO;
}
@end