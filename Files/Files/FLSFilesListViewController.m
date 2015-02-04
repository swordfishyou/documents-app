//
//  FLSFilesListViewController.m
//  Files
//
//  Created by Anatoly Tukhtarov on 1/27/15.
//  Copyright (c) 2015 Ciklum. All rights reserved.
//

#import "FLSFilesListViewController.h"
#import "FLSDataSource.h"
#import "FLSDocument.h"
#import "FLSWaterfallCollectionViewLayout.h"
#import "FLSGesturesController.h"

@interface FLSFilesListViewController () <FLSWaterfallCollectionViewLayoutDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) FLSDataSource *dataSource;
@property (nonatomic, strong) FLSGesturesController *gesturesController;

- (IBAction)addDocumentButtonTapHandler:(UIBarButtonItem *)sender;
- (void)configureCollectionView;
@end

@implementation FLSFilesListViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureCollectionView];
    self.gesturesController = [[FLSGesturesController alloc] initWithCollectionView:self.collectionView];
}

#pragma mark - Private
- (void)configureCollectionView {
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    self.dataSource = [FLSDataSource new];
    self.collectionView.dataSource = self.dataSource;
    
    FLSWaterfallCollectionViewLayout *layout = (FLSWaterfallCollectionViewLayout *)self.collectionView.collectionViewLayout;
    if ([layout isKindOfClass:[FLSWaterfallCollectionViewLayout class]]) {
        layout.delegate = self;
    }
}

#pragma mark - Events handling
- (IBAction)addDocumentButtonTapHandler:(UIBarButtonItem *)sender {
    NSString *title = @"Document";
    NSInteger numberOfItems = self.dataSource.documents.count;
    if (numberOfItems > 0) {
        title = [title stringByAppendingFormat:@" %lu", (unsigned long)numberOfItems];
    }
    
    NSInteger random = arc4random_uniform((u_int32_t)numberOfItems);
    NSString *imageName = ((numberOfItems + 1) % (random + 1)) ? @"100x141" : @"141x100";
    FLSDocument *documet = [[FLSDocument alloc] initWithTitle:title
                                                 creationDate:[NSDate date]
                                                      preview:[UIImage imageNamed:imageName]];
    [self.dataSource addDocument:documet];
    [self.collectionView insertItemsAtIndexPaths:@[[self.dataSource indexPathForDocument:documet]]];
}

#pragma mark - FLSWaterfallCollectionViewLayoutDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView waterfallLayout:(FLSWaterfallCollectionViewLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    BOOL isPad = (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad);
    NSInteger numberOfColumns = isPad ? 4 : 2;
    CGRect bounds = collectionView.bounds;
    if (CGRectGetHeight(bounds) < CGRectGetWidth(bounds)) {
        numberOfColumns = isPad ? 5 : 3;
    }
    
    return numberOfColumns;
}
@end