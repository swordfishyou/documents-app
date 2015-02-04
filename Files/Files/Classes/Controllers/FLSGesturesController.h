//
//  FLSGesturesController.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/30/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@interface FLSGesturesController : NSObject
@property (nonatomic, readonly, weak) UICollectionView *collectionView;
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;
@end
