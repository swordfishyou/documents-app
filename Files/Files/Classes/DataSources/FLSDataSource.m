//
//  FLSDataSource.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/28/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSDataSource.h"
#import "FLSCollectionViewCell.h"

@interface FLSDataSource ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation FLSDataSource
- (instancetype)init {
    if (self = [super init]) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.dateStyle = kCFDateFormatterMediumStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.locale = [NSLocale currentLocale];
        _dateFormatter.timeZone = [NSTimeZone systemTimeZone];
        _documents = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Documents
- (void)addDocument:(FLSDocument *)document {
    NSParameterAssert(document);
    [self.documents addObject:document];
}

- (void)removeDocument:(FLSDocument *)document {
    NSParameterAssert(document);
    [self.documents removeObject:document];
}

- (NSIndexPath *)indexPathForDocument:(FLSDocument *)document {
    NSParameterAssert(document);
    NSInteger item = [self.documents indexOfObject:document];
    return [NSIndexPath indexPathForItem:item inSection:0];
}

-(FLSDocument *)documentAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    NSAssert(indexPath.item < self.documents.count, @"There is no document at indexPath %@", indexPath);
    return self.documents[indexPath.item];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.documents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FLSCollectionViewCell class]) forIndexPath:indexPath];
    [cell configureWithDocument:[self documentAtIndexPath:indexPath] dateFormatter:self.dateFormatter];
    return cell;
}

#pragma mark - FLSDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView
         sizeFittingSize:(CGSize)fittingSize
      forItemAtIndexPath:(NSIndexPath *)indexPath {
    FLSCollectionViewCell *cell = (FLSCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    frame.size = fittingSize;
    cell.frame = frame;
    
    CGSize size;
    [cell layoutIfNeeded];
    size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [cell removeFromSuperview];
    
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath
                isHeld:(BOOL)held {
    if (held) {
        if (fromIndexPath.item == toIndexPath.item) {
            return;
        }
        
        NSInteger numberOfItems = [self.documents count];
        if (fromIndexPath.item >= numberOfItems) {
            return;
        }
        
        NSInteger toIndex = toIndexPath.item;
        if (toIndex >= numberOfItems) {
            toIndex = numberOfItems - 1;
        }
        
        NSMutableArray *documents = [self.documents mutableCopy];
        id movingObject = documents[fromIndexPath.item];
        [documents removeObjectAtIndex:fromIndexPath.item];
        [documents insertObject:movingObject atIndex:toIndex];
        
        _documents = documents;
        [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}
@end