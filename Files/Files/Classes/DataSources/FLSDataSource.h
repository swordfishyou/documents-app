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

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath isHeld:(BOOL)held;
@end