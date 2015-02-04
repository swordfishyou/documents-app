//
//  FLSDataSource.h
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

@import UIKit;

@class FLSDocument;

@interface FLSDataSource : NSObject <UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *documents;

- (void)addDocument:(FLSDocument *)document;
- (void)removeDocument:(FLSDocument *)document;

- (NSIndexPath *)indexPathForDocument:(FLSDocument *)document;
- (FLSDocument *)documentAtIndexPath:(NSIndexPath *)indexPath;

/// Returns size of the cell at given index path. Cell has to be built using autolayout.
/// Called by collectionView's layout object while preparing layout
- (CGSize)collectionView:(UICollectionView *)collectionView
         sizeFittingSize:(CGSize)size
      forItemAtIndexPath:(NSIndexPath *)indexPath;
/// Indicates item can be moved from one index path to another. Called by collectionView's layout object on
/// drag and drop when item was held on valid position
- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath;
/// Called by collectionView's layout object on drag and drop when item was held on valid position if
/// -collectionView:canMoveItemAtIndexPath:toIndexPath returns YES
- (void)collectionView:(UICollectionView *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath
                isHeld:(BOOL)held;
@end